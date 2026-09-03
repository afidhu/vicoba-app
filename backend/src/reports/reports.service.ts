import { Injectable, NotFoundException } from '@nestjs/common';
// import { FineStatus, LoanStatus } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

interface DateRange {
  from?: string;
  to?: string;
}

@Injectable()
export class ReportsService {
  constructor(private prisma: PrismaService) {}

  private dateFilter(field: string, range: DateRange) {
    if (!range.from && !range.to) return {};
    return {
      [field]: {
        ...(range.from ? { gte: new Date(range.from) } : {}),
        ...(range.to ? { lte: new Date(range.to) } : {}),
      },
    };
  }

  async contributionsReport(groupId: string, range: DateRange) {
    const contributions = await this.prisma.contribution.findMany({
      where: { groupId, ...this.dateFilter('weekEnding', range) },
      include: { member: { select: { id: true, name: true } } },
      orderBy: { weekEnding: 'desc' },
    });
    const total = contributions.reduce((sum, c) => sum + Number(c.amount), 0);
    return { total, count: contributions.length, contributions };
  }

  async sharesReport(groupId: string) {
    const group = await this.prisma.group.findUnique({ where: { id: groupId } });
    if (!group) throw new NotFoundException('Group not found');
    const members = await this.prisma.groupMember.findMany({ where: { groupId } });
    const sharePrice = Number(group.sharePrice);
    const breakdown = members.map((m) => ({
      memberId: m.id,
      name: m.name,
      shareHoldings: m.shareHoldings,
      shareValue: m.shareHoldings * sharePrice,
    }));
    const totalShares = breakdown.reduce((s, m) => s + m.shareHoldings, 0);
    return { sharePrice, totalShares, totalShareCapital: totalShares * sharePrice, breakdown };
  }

  async finesReport(groupId: string, range: DateRange) {
    const fines = await this.prisma.fine.findMany({
      where: { groupId, ...this.dateFilter('createdAt', range) },
      include: { member: { select: { id: true, name: true } } },
      orderBy: { createdAt: 'desc' },
    });
    const totalUnpaid = fines
      .filter((f) => f.status === 'UNPAID')
      .reduce((s, f) => s + Number(f.amount), 0);
    const totalPaid = fines
      .filter((f) => f.status === 'PAID')
      .reduce((s, f) => s + Number(f.amount), 0);
    return { totalUnpaid, totalPaid, count: fines.length, fines };
  }

  async loansReport(groupId: string, range: DateRange) {
    const loans = await this.prisma.loan.findMany({
      where: { groupId, ...this.dateFilter('issueDate', range) },
      include: { member: { select: { id: true, name: true } }, repayments: true },
      orderBy: { issueDate: 'desc' },
    });

    let totalDisbursed = 0;
    let totalOutstanding = 0;
    const decorated = loans.map((loan) => {
      const totalRepaid = loan.repayments.reduce((s, r) => s + Number(r.amount), 0);
      const totalOwed =
        Number(loan.principal) + Number(loan.principal) * (Number(loan.interestRate) / 100);
      const outstanding = loan.status === 'PAID' ? 0 : Math.max(0, totalOwed - totalRepaid);
      totalDisbursed += Number(loan.principal);
      totalOutstanding += outstanding;
      return { ...loan, totalRepaid, outstanding };
    });

    return {
      totalDisbursed,
      totalOutstanding: Math.round(totalOutstanding * 100) / 100,
      count: loans.length,
      loans: decorated,
    };
  }

  async expensesReport(groupId: string, range: DateRange) {
    const expenses = await this.prisma.expense.findMany({
      where: { groupId, ...this.dateFilter('date', range) },
      orderBy: { date: 'desc' },
    });
    const total = expenses.reduce((s, e) => s + Number(e.amount), 0);
    return { total, count: expenses.length, expenses };
  }

  async transactionsReport(groupId: string, range: DateRange) {
    const transactions = await this.prisma.transaction.findMany({
      where: { groupId, ...this.dateFilter('createdAt', range) },
      include: { member: { select: { id: true, name: true } } },
      orderBy: { createdAt: 'desc' },
    });
    const totalIn = transactions
      .filter((t) => t.direction === 'IN')
      .reduce((s, t) => s + Number(t.amount), 0);
    const totalOut = transactions
      .filter((t) => t.direction === 'OUT')
      .reduce((s, t) => s + Number(t.amount), 0);
    return { totalIn, totalOut, netMovement: totalIn - totalOut, transactions };
  }

  async financialSummary(groupId: string, range: DateRange) {
    const [contrib, fines, loans, expenses, transactions] = await Promise.all([
      this.contributionsReport(groupId, range),
      this.finesReport(groupId, range),
      this.loansReport(groupId, range),
      this.expensesReport(groupId, range),
      this.transactionsReport(groupId, range),
    ]);
    return {
      contributions: { total: contrib.total, count: contrib.count },
      fines: { totalUnpaid: fines.totalUnpaid, totalPaid: fines.totalPaid, count: fines.count },
      loans: {
        totalDisbursed: loans.totalDisbursed,
        totalOutstanding: loans.totalOutstanding,
        count: loans.count,
      },
      expenses: { total: expenses.total, count: expenses.count },
      cashFlow: {
        totalIn: transactions.totalIn,
        totalOut: transactions.totalOut,
        netMovement: transactions.netMovement,
      },
    };
  }
}
