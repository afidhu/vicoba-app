import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';
// import { TransactionDirection, TransactionType } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { AuditService } from '../audit/audit.service';
import { CreateMemberDto } from './dto/create-member.dto';
import { UpdateMemberDto } from './dto/update-member.dto';
import { PurchaseSharesDto } from './dto/purchase-shares.dto';

@Injectable()
export class MembersService {
  constructor(
    private prisma: PrismaService,
    private audit: AuditService,
  ) {}

  async create(groupId: string, actorUserId: string, dto: CreateMemberDto) {
    if (dto.phone) {
      const existing = await this.prisma.groupMember.findFirst({
        where: { groupId, phone: dto.phone },
      });
      if (existing) {
        throw new ConflictException('A member with this phone number already exists in this group');
      }
    }

    let userId = dto.userId;

    // Owner/officer is registering this member with their own login.
    if (!userId && dto.email && dto.password) {
      const existingUser = await this.prisma.user.findUnique({
        where: { email: dto.email },
      });
      if (existingUser) {
        throw new ConflictException('An account with this email already exists');
      }
      const passwordHash = await bcrypt.hash(dto.password, 10);
      const newUser = await this.prisma.user.create({
        data: {
          email: dto.email,
          passwordHash,
          name: dto.name,
          phone: dto.phone,
        },
      });
      userId = newUser.id;
    }

    const member = await this.prisma.groupMember.create({
      data: {
        groupId,
        name: dto.name,
        phone: dto.phone,
        role: dto.role as any,
        userId,
      },
    });

    await this.audit.log({
      userId: actorUserId,
      action: 'CREATE',
      entity: 'GroupMember',
      entityId: member.id,
      groupId,
    });

    return member;
  }

  findAll(groupId: string, memberId?: string) {
    return this.prisma.groupMember.findMany({
      where: { groupId, ...(memberId ? { id: memberId } : {}) },
      orderBy: { joinedAt: 'asc' },
    });
  }

  async findOne(groupId: string, memberId: string) {
    const member = await this.prisma.groupMember.findFirst({
      where: { id: memberId, groupId },
    });
    if (!member) throw new NotFoundException('Member not found');
    return member;
  }

  async update(
    groupId: string,
    memberId: string,
    actorUserId: string,
    dto: UpdateMemberDto,
  ) {
    await this.findOne(groupId, memberId);
    const member = await this.prisma.groupMember.update({
      where: { id: memberId },
      data: { ...dto as any},
    });

    await this.audit.log({
      userId: actorUserId,
      action: 'UPDATE',
      entity: 'GroupMember',
      entityId: memberId,
      groupId,
      metadata: dto as Record<string, any>,
    });

    return member;
  }

  async purchaseShares(
    groupId: string,
    memberId: string,
    actorUserId: string,
    dto: PurchaseSharesDto,
  ) {
    const [member, group] = await Promise.all([
      this.findOne(groupId, memberId),
      this.prisma.group.findUnique({ where: { id: groupId } }),
    ]);
    if (!group) throw new NotFoundException('Group not found');
    if (!member.isActive) {
      throw new BadRequestException('Cannot record shares for an inactive member');
    }

    const totalCost = Number(group.sharePrice) * dto.quantity;

    const [updatedMember, transaction] = await this.prisma.$transaction([
      this.prisma.groupMember.update({
        where: { id: memberId },
        data: { shareHoldings: { increment: dto.quantity } },
      }),
      this.prisma.transaction.create({
        data: {
          groupId,
          memberId,
          type: 'SHARE_PURCHASE',
          direction: 'IN',
          amount: totalCost,
          description: `Purchase of ${dto.quantity} share(s)`,
        },
      }),
    ]);

    await this.audit.log({
      userId: actorUserId,
      action: 'PURCHASE_SHARES',
      entity: 'GroupMember',
      entityId: memberId,
      groupId,
      metadata: { quantity: dto.quantity, totalCost },
    });

    return { member: updatedMember, transaction };
  }

  async shareSummary(groupId: string, memberId?: string) {
    const [group, members] = await Promise.all([
      this.prisma.group.findUnique({ where: { id: groupId } }),
      this.prisma.groupMember.findMany({ where: { groupId } }),
    ]);
    if (!group) throw new NotFoundException('Group not found');

    const sharePrice = Number(group.sharePrice);
    const toRow = (m: (typeof members)[number]) => ({
      memberId: m.id,
      name: m.name,
      shareHoldings: m.shareHoldings,
      shareValue: m.shareHoldings * sharePrice,
    });

    // Group totals always reflect every member; the breakdown rows are what a
    // plain MEMBER doesn't get to see beyond their own.
    const totalShares = members.reduce((sum, m) => sum + m.shareHoldings, 0);
    const totalShareCapital = totalShares * sharePrice;
    const breakdown = (memberId ? members.filter((m) => m.id === memberId) : members).map(toRow);

    return { sharePrice, totalShares, totalShareCapital, breakdown };
  }
}
