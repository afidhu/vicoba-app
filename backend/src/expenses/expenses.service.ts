import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { AuditService } from '../audit/audit.service';
import { CreateExpenseDto } from './dto/create-expense.dto';

@Injectable()
export class ExpensesService {
  constructor(
    private prisma: PrismaService,
    private audit: AuditService,
  ) {}

  async create(groupId: string, actorUserId: string, dto: CreateExpenseDto) {
    const group = await this.prisma.group.findUnique({ where: { id: groupId } });
    if (!group) throw new NotFoundException('Group not found');

    const [expense, transaction] = await this.prisma.$transaction([
      this.prisma.expense.create({
        data: {
          groupId,
          description: dto.description,
          amount: dto.amount,
          date: new Date(dto.date),
        },
      }),
      this.prisma.transaction.create({
        data: {
          groupId,
          type: "EXPENSE",
          direction: "OUT",
          amount: dto.amount,
          description: dto.description,
        },
      }),
    ]);

    await this.audit.log({
      userId: actorUserId,
      action: 'CREATE',
      entity: 'Expense',
      entityId: expense.id,
      groupId,
      metadata: { amount: dto.amount, description: dto.description },
    });

    return { expense, transaction };
  }

  findAll(groupId: string) {
    return this.prisma.expense.findMany({
      where: { groupId },
      orderBy: { date: 'desc' },
    });
  }
}
