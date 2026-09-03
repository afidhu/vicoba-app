import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { AuditService } from '../audit/audit.service';
import { CreateFineDto } from './dto/create-fine.dto';
import { UpdateFineStatusDto } from './dto/update-fine-status.dto';

@Injectable()
export class FinesService {
  constructor(
    private prisma: PrismaService,
    private audit: AuditService,
  ) {}

  async create(groupId: string, actorUserId: string, dto: CreateFineDto) {
    const [member, group] = await Promise.all([
      this.prisma.groupMember.findFirst({ where: { id: dto.memberId, groupId } }),
      this.prisma.group.findUnique({ where: { id: groupId } }),
    ]);
    if (!member) throw new NotFoundException('Member not found in this group');
    if (!group) throw new NotFoundException('Group not found');

    const amount = dto.amount ?? Number(group.fineDefaultAmount);
    if (!amount || amount <= 0) {
      throw new BadRequestException(
        'A fine amount is required (the group has no default fine amount set)',
      );
    }

    const fine = await this.prisma.fine.create({
      data: { groupId, memberId: dto.memberId, reason: dto.reason, amount },
    });

    await this.audit.log({
      userId: actorUserId,
      action: 'CREATE',
      entity: 'Fine',
      entityId: fine.id,
      groupId,
      metadata: { memberId: dto.memberId, amount, reason: dto.reason },
    });

    return fine;
  }

  findAll(groupId: string, memberId?: string, status?: string) {
    return this.prisma.fine.findMany({
      where: { groupId, ...(memberId ? { memberId } : {}), ...(status ? { status: status as any } : {}) },
      include: { member: { select: { id: true, name: true } } },
      orderBy: { createdAt: 'desc' },
    });
  }

  async updateStatus(
    groupId: string,
    fineId: string,
    actorUserId: string,
    dto: UpdateFineStatusDto,
  ) {
    const fine = await this.prisma.fine.findFirst({ where: { id: fineId, groupId } });
    if (!fine) throw new NotFoundException('Fine not found');

    const updated = await this.prisma.fine.update({
      where: { id: fineId },
      data: { status: dto.status as any },
    });

    if (dto.status === "PAID" && fine.status !== "PAID") {
      await this.prisma.transaction.create({
        data: {
          groupId,
          memberId: fine.memberId,
          type: "FINE",
          direction: "IN",
          amount: fine.amount,
          description: `Fine paid: ${fine.reason}`,
          refId: fine.id,
        },
      });
    }

    await this.audit.log({
      userId: actorUserId,
      action: 'UPDATE_STATUS',
      entity: 'Fine',
      entityId: fineId,
      groupId,
      metadata: { status: dto.status as any },
    });

    return updated;
  }
}
