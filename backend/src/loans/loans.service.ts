import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
// import { LoanStatus, TransactionDirection, TransactionType } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { AuditService } from '../audit/audit.service';
import { assertOwnRecordOrPrivileged } from '../common/utils/member-scope';
import { getPledgedSharesByGuarantor } from '../common/utils/share-pledges';
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

  private shareValueOf(member: { shareHoldings: number }, group: { sharePrice: any }) {
    return member.shareHoldings * Number(group.sharePrice);
  }

  private async computeAvailableShareValue(
    groupId: string,
    memberId: string,
    member: { shareHoldings: number },
    group: { sharePrice: any },
  ) {
    const pledgedMap = await getPledgedSharesByGuarantor(this.prisma, groupId);
    const pledgedShares = pledgedMap.get(memberId) ?? 0;
    return this.shareValueOf(member, group) - pledgedShares * Number(group.sharePrice);
  }

  /**
   * Enforces the "guarantor required when the borrower's own shares don't
   * cover the loan" rule shared by create() and request(). Returns the
   * guarantorId/guaranteedShares to persist (both null when no guarantor is
   * needed), or throws if the rule is violated.
   */
  private async resolveGuarantor(
    groupId: string,
    borrowerMemberId: string,
    principal: number,
    guarantorId: string | undefined,
    borrower: { shareHoldings: number },
    group: { sharePrice: any },
  ): Promise<{ guarantorId: string | null; guaranteedShares: number | null }> {
    const borrowerShareValue = this.shareValueOf(borrower, group);
    if (principal <= borrowerShareValue) {
      return { guarantorId: null, guaranteedShares: null };
    }

    if (!guarantorId) {
      throw new BadRequestException(
        "This loan exceeds the borrower's share value; a guarantor is required",
      );
    }
    if (guarantorId === borrowerMemberId) {
      throw new BadRequestException('A member cannot guarantee their own loan');
    }

    const guarantor = await this.prisma.groupMember.findFirst({
      where: { id: guarantorId, groupId },
    });
    if (!guarantor) throw new NotFoundException('Guarantor not found in this group');
    if (!guarantor.isActive) {
      throw new BadRequestException('Guarantor must be an active member');
    }

    const shortfall = principal - borrowerShareValue;
    const guarantorAvailable = await this.computeAvailableShareValue(
      groupId,
      guarantorId,
      guarantor,
      group,
    );
    if (guarantorAvailable < shortfall) {
      throw new BadRequestException(
        'Guarantor does not have enough available shares to cover this loan',
      );
    }

    const guaranteedShares = Math.ceil(shortfall / Number(group.sharePrice));
    return { guarantorId, guaranteedShares };
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
    const { guarantorId, guaranteedShares } = await this.resolveGuarantor(
      groupId,
      dto.memberId,
      dto.principal,
      dto.guarantorId,
      member,
      group,
    );

    const [loan, transaction] = await this.prisma.$transaction([
      this.prisma.loan.create({
        data: {
          groupId,
          memberId: dto.memberId,
          guarantorId,
          guaranteedShares,
          principal: dto.principal,
          interestRate,
          issueDate: new Date(dto.issueDate),
          dueDate: new Date(dto.dueDate),
        },
        include: {
          member: { select: { id: true, name: true } },
          guarantor: { select: { id: true, name: true } },
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
      metadata: {
        memberId: dto.memberId,
        principal: dto.principal,
        ...(guarantorId ? { guarantorId, guaranteedShares } : {}),
      },
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
    if (!group) throw new NotFoundException('Group not found');

    const { guarantorId, guaranteedShares } = await this.resolveGuarantor(
      groupId,
      memberId,
      dto.principal,
      dto.guarantorId,
      member,
      group,
    );

    const loan = await this.prisma.loan.create({
      data: {
        groupId,
        memberId,
        guarantorId,
        guaranteedShares,
        principal: dto.principal,
        interestRate: Number(group.loanInterestRate ?? 0),
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
      metadata: {
        memberId,
        principal: dto.principal,
        notes: dto.notes,
        ...(guarantorId ? { guarantorId, guaranteedShares } : {}),
      },
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

    const guarantor = updated.guarantorId
      ? await this.prisma.groupMember.findUnique({
          where: { id: updated.guarantorId },
          select: { id: true, name: true },
        })
      : undefined;

    return this.decorateLoan({ ...updated, member: undefined, guarantor, repayments: [] });
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

    const guarantor = updated.guarantorId
      ? await this.prisma.groupMember.findUnique({
          where: { id: updated.guarantorId },
          select: { id: true, name: true },
        })
      : undefined;

    return this.decorateLoan({ ...updated, member: undefined, guarantor, repayments: [] });
  }

  async findAll(groupId: string, memberId?: string, status?: string) {
    const loans = await this.prisma.loan.findMany({
      where: { groupId, ...(memberId ? { memberId } : {}), ...(status ? { status: status as any } : {}) },
      include: {
        member: { select: { id: true, name: true } },
        guarantor: { select: { id: true, name: true } },
        repayments: true,
      },
      orderBy: { issueDate: 'desc' },
    });

    return loans.map((loan) => this.decorateLoan(loan));
  }

  async findOne(groupId: string, loanId: string, membership?: { id: string; role: string }) {
    const loan = await this.prisma.loan.findFirst({
      where: { id: loanId, groupId },
      include: {
        member: { select: { id: true, name: true } },
        guarantor: { select: { id: true, name: true } },
        repayments: true,
      },
    });
    if (!loan) throw new NotFoundException('Loan not found');
    if (membership) assertOwnRecordOrPrivileged(membership, loan.memberId);
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

    const newOutstanding = outstandingBefore - dto.amount;
    const willBePaid = newOutstanding <= 0;

    const ops: any[] = [
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
    ];
    if (willBePaid) {
      ops.push(
        this.prisma.loan.update({
          where: { id: loanId },
          data: { status: "PAID" },
        }),
      );
    }

    const [repayment, transaction] = await this.prisma.$transaction(ops);

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
