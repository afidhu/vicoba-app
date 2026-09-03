import { Injectable } from '@nestjs/common';
// import { TransactionType } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class TransactionsService {
  constructor(private prisma: PrismaService) {}

  findAll(
    groupId: string,
    filters: { memberId?: string; type?: string; from?: string; to?: string },
  ) {
    return this.prisma.transaction.findMany({
      where: {
        groupId,
        ...(filters.memberId ? { memberId: filters.memberId } : {}),
        ...(filters.type ? { type: filters.type as any } : {}),
        ...(filters.from || filters.to
          ? {
              createdAt: {
                ...(filters.from ? { gte: new Date(filters.from) } : {}),
                ...(filters.to ? { lte: new Date(filters.to) } : {}),
              },
            }
          : {}),
      },
      include: { member: { select: { id: true, name: true } } },
      orderBy: { createdAt: 'desc' },
    });
  }

  auditLog(groupId: string) {
    return this.prisma.auditLog.findMany({
      where: { groupId },
      include: { user: { select: { id: true, name: true, email: true } } },
      orderBy: { createdAt: 'desc' },
      take: 200,
    });
  }
}
