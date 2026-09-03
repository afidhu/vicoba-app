import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
// import { LoanStatus, TransactionDirection, TransactionType } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { AuditService } from '../audit/audit.service';
import { CreateLoanDto } from './dto/create-loan.dto';
import { RepayLoanDto } from './dto/repay-loan.dto';
import { RequestLoanDto } from './dto/request-loan.dto';
import { ApproveLoanDto } from './dto/approve-loan.dto';

@Injectable()
export class LoansService {
  constructor(
    private prisma: PrismaService,
    private audit: AuditService,
  ) {}

  /** Simple flat interest: outstanding = principal + (principal * rate% ) - totalRepaid */
  private computeOutstanding(
    principal: number,
    interestRate: number,
    totalRepaid: number,
  ) {
    const totalOwed = principal + principal * (interestRate / 100);
    return Math.max(0, Math.round((totalOwed - totalRepaid) * 100) / 100);
  }

  async create(groupId: string, actorUserId: string, dto: CreateLoanDto) {
    const [member, group] = await Promise.all([
      this.prisma.groupMember.findFirst({ where: { id: dto.memberId, groupId } }),
      this.prisma.group.findUnique({ where: { id: groupId } }),
    ]);
    if (!member) throw new NotFoundException('Member not found in this group');
    if (!group) throw new NotFoundException('Group not found');
    if (!member.isActive) {
      throw new BadRequestException('Cannot issue a loan to an inactive member');
    }

    const interestRate = dto.interestRate ?? Number(group.loanInterestRate);

    const [loan, transaction] = await this.prisma.$transaction([
      this.prisma.loan.create({
        data: {
          groupId,
          memberId: dto.memberId,
          principal: dto.principal,
          interestRate,
          issueDate: new Date(dto.issueDate),
          dueDate: new Date(dto.dueDate),
        },
      }),
      this.prisma.transaction.create({
        data: {
          groupId,
          memberId: dto.memberId,
          type: "LOAN_DISBURSEMENT",
          direction: "OUT",
          amount: dto.principal,
          description: 'Loan disbursed',
        },
      }),
    ]);

    await this.audit.log({
      userId: actorUserId,
      action: 'CREATE',
      entity: 'Loan',
      entityId: loan.id,
      groupId,
      metadata: { memberId: dto.memberId, principal: dto.principal },
    });

    return loan;
  }

  /** Member-initiated loan request. Stays PENDING until an officer approves it. */
  async request(groupId: string, actorUserId: string, dto: RequestLoanDto) {
    const actorMembership = await this.prisma.groupMember.findFirst({
      where: { groupId, userId: actorUserId, isActive: true },
    });
    if (!actorMembership) {
      throw new BadRequestException('You are not an active member of this group');
    }

    const isOfficer = ['OWNER', 'ADMIN', 'TREASURER'].includes(
      actorMembership.role,
    );
    // Officers may raise a request on behalf of any member; everyone else only
    // for their own membership.
    const memberId =
      isOfficer && dto.memberId ? dto.memberId : actorMembership.id;

    const member = await this.prisma.groupMember.findFirst({
      where: { id: memberId, groupId },
    });
    if (!member) throw new NotFoundException('Member not found in this group');
    if (!member.isActive) {
      throw new BadRequestException('Inactive members cannot take loans');
    }

    const group = await this.prisma.group.findUnique({ where: { id: groupId } });

    const loan = await this.prisma.loan.create({
      data: {
        groupId,
        memberId,
        principal: dto.principal,
        interestRate: Number(group?.loanInterestRate ?? 0),
        status: 'PENDING',
        requestedById: actorMembership.id,
        dueDate: dto.dueDate ? new Date(dto.dueDate) : null,
      },
    });

    await this.audit.log({
      userId: actorUserId,
      action: 'REQUEST',
      entity: 'Loan',
      entityId: loan.id,
      groupId,
      metadata: { memberId, principal: dto.principal, notes: dto.notes },
    });

    return this.findOne(groupId, loan.id);
  }

  async approve(
    groupId: string,
    loanId: string,
    actorUserId: string,
    dto: ApproveLoanDto,
  ) {
    const loan = await this.prisma.loan.findFirst({ where: { id: loanId, groupId } });
    if (!loan) throw new NotFoundException('Loan not found');
    if (loan.status !== 'PENDING') {
      throw new BadRequestException('Only pending loan requests can be approved');
    }

    const actorMembership = await this.prisma.groupMember.findFirst({
      where: { groupId, userId: actorUserId },
    });
    const group = await this.prisma.group.findUnique({ where: { id: groupId } });

    const issueDate = dto.issueDate ? new Date(dto.issueDate) : new Date();
    const dueDate = dto.dueDate
      ? new Date(dto.dueDate)
      : loan.dueDate ??
        new Date(issueDate.getTime() + 30 * 24 * 60 * 60 * 1000);
    const interestRate =
      dto.interestRate ?? Number(loan.interestRate) ??
      Number(group?.loanInterestRate ?? 0);

    const [updated] = await this.prisma.$transaction([
      this.prisma.loan.update({
        where: { id: loanId },
        data: {
          status: 'ACTIVE',
          issueDate,
          dueDate,
          interestRate,
          decidedById: actorMembership?.id,
          decidedAt: new Date(),
        },
      }),
      this.prisma.transaction.create({
        data: {
          groupId,
          memberId: loan.memberId,
          type: 'LOAN_DISBURSEMENT',
          direction: 'OUT',
          amount: loan.principal,
          description: 'Loan disbursed',
          refId: loanId,
        },
      }),
    ]);

    await this.audit.log({
      userId: actorUserId,
      action: 'APPROVE',
      entity: 'Loan',
      entityId: loanId,
      groupId,
      metadata: { principal: Number(loan.principal) },
    });

    return this.decorateLoan({ ...updated, member: undefined, repayments: [] });
  }

  async reject(groupId: string, loanId: string, actorUserId: string) {
    const loan = await this.prisma.loan.findFirst({ where: { id: loanId, groupId } });
    if (!loan) throw new NotFoundException('Loan not found');
    if (loan.status !== 'PENDING') {
      throw new BadRequestException('Only pending loan requests can be rejected');
    }

    const actorMembership = await this.prisma.groupMember.findFirst({
      where: { groupId, userId: actorUserId },
    });

    const updated = await this.prisma.loan.update({
      where: { id: loanId },
      data: {
        status: 'REJECTED',
        decidedById: actorMembership?.id,
        decidedAt: new Date(),
      },
    });

    await this.audit.log({
      userId: actorUserId,
      action: 'REJECT',
      entity: 'Loan',
      entityId: loanId,
      groupId,
    });

    return this.decorateLoan({ ...updated, member: undefined, repayments: [] });
  }

  async findAll(groupId: string, memberId?: string, status?: string) {
    const loans = await this.prisma.loan.findMany({
      where: { groupId, ...(memberId ? { memberId } : {}), ...(status ? { status: status as any } : {}) },
      include: {
        member: { select: { id: true, name: true } },
        repayments: true,
      },
      orderBy: { issueDate: 'desc' },
    });

    return loans.map((loan) => this.decorateLoan(loan));
  }

  async findOne(groupId: string, loanId: string) {
    const loan = await this.prisma.loan.findFirst({
      where: { id: loanId, groupId },
      include: { member: { select: { id: true, name: true } }, repayments: true },
    });
    if (!loan) throw new NotFoundException('Loan not found');
    return this.decorateLoan(loan);
  }

  private decorateLoan(loan: any) {
    const totalRepaid = loan.repayments.reduce(
      (sum: number, r: any) => sum + Number(r.amount),
      0,
    );
    const outstanding = this.computeOutstanding(
      Number(loan.principal),
      Number(loan.interestRate),
      totalRepaid,
    );
    const isOverdue =
      loan.status === "ACTIVE" &&
      !!loan.dueDate &&
      new Date(loan.dueDate).getTime() < Date.now() &&
      outstanding > 0;

    return { ...loan, totalRepaid, outstanding, isOverdue };
  }

  async repay(groupId: string, loanId: string, actorUserId: string, dto: RepayLoanDto) {
    const loan = await this.prisma.loan.findFirst({
      where: { id: loanId, groupId },
      include: { repayments: true },
    });
    if (!loan) throw new NotFoundException('Loan not found');
    if (loan.status === "PAID") {
      throw new BadRequestException('This loan has already been fully repaid');
    }
    if (loan.status === "PENDING" || loan.status === "REJECTED") {
      throw new BadRequestException('This loan has not been approved yet');
    }

    const totalRepaidSoFar = loan.repayments.reduce(
      (sum, r) => sum + Number(r.amount),
      0,
    );
    const outstandingBefore = this.computeOutstanding(
      Number(loan.principal),
      Number(loan.interestRate),
      totalRepaidSoFar,
    );

    if (dto.amount > outstandingBefore) {
      throw new BadRequestException(
        `Repayment amount exceeds outstanding balance of ${outstandingBefore}`,
      );
    }

    const [repayment, transaction] = await this.prisma.$transaction([
      this.prisma.loanRepayment.create({
        data: { loanId, amount: dto.amount },
      }),
      this.prisma.transaction.create({
        data: {
          groupId,
          memberId: loan.memberId,
          type: "LOAN_REPAYMENT",
          direction: "IN",
          amount: dto.amount,
          description: 'Loan repayment',
          refId: loanId,
        },
      }),
    ]);

    const newOutstanding = outstandingBefore - dto.amount;
    if (newOutstanding <= 0) {
      await this.prisma.loan.update({
        where: { id: loanId },
        data: { status: "PAID" },
      });
    }

    await this.audit.log({
      userId: actorUserId,
      action: 'REPAY',
      entity: 'Loan',
      entityId: loanId,
      groupId,
      metadata: { amount: dto.amount },
    });

    return { repayment, transaction, outstanding: Math.max(0, newOutstanding) };
  }
}
