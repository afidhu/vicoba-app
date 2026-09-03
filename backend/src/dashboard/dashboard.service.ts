import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class DashboardService {
  constructor(private prisma: PrismaService) {}

  async getSummary(groupId: string) {
    const group = await this.prisma.group.findUnique({ where: { id: groupId } });
    if (!group) throw new NotFoundException('Group not found');

    const [
      members,
      contributions,
      fines,
      loans,
      expenses,
      recentTransactions,
    ] = await Promise.all([
      this.prisma.groupMember.findMany({ where: { groupId } }),
      this.prisma.contribution.aggregate({
        where: { groupId },
        _sum: { amount: true },
      }),
      this.prisma.fine.findMany({ where: { groupId } }),
      this.prisma.loan.findMany({ where: { groupId }, include: { repayments: true } }),
      this.prisma.expense.aggregate({ where: { groupId }, _sum: { amount: true } }),
      this.prisma.transaction.findMany({
        where: { groupId },
        include: { member: { select: { id: true, name: true } } },
        orderBy: { createdAt: 'desc' },
        take: 10,
      }),
    ]);

    const activeMembers = members.filter((m) => m.isActive);
    const sharePrice = Number(group.sharePrice);
    const totalShares = members.reduce((sum, m) => sum + m.shareHoldings, 0);
    const totalShareCapital = totalShares * sharePrice;

    const unpaidFinesTotal = fines
      .filter((f) => f.status === "UNPAID")
      .reduce((sum, f) => sum + Number(f.amount), 0);

    let outstandingLoansTotal = 0;
    let activeLoanCount = 0;
    for (const loan of loans) {
      if (loan.status === "PAID") continue;
      const totalRepaid = loan.repayments.reduce((s, r) => s + Number(r.amount), 0);
      const totalOwed =
        Number(loan.principal) + Number(loan.principal) * (Number(loan.interestRate) / 100);
      const outstanding = Math.max(0, totalOwed - totalRepaid);
      outstandingLoansTotal += outstanding;
      if (outstanding > 0) activeLoanCount += 1;
    }

    return {
      group: {
        id: group.id,
        name: group.name,
        location: group.location,
        meetingDay: group.meetingDay,
        weeklyContribution: group.weeklyContribution,
        sharePrice: group.sharePrice,
        fineDefaultAmount: group.fineDefaultAmount,
        loanInterestRate: group.loanInterestRate,
      },
      counts: {
        totalMembers: members.length,
        activeMembers: activeMembers.length,
        activeLoans: activeLoanCount,
      },
      totals: {
        totalContributions: contributions._sum.amount ?? 0,
        totalShareCapital,
        outstandingLoans: Math.round(outstandingLoansTotal * 100) / 100,
        unpaidFines: unpaidFinesTotal,
        totalExpenses: expenses._sum.amount ?? 0,
      },
      recentTransactions,
    };
  }
}
