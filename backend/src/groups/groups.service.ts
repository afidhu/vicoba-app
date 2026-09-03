import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
// import { GroupRole } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { AuditService } from '../audit/audit.service';
import { CreateGroupDto } from './dto/create-group.dto';
import { UpdateGroupDto } from './dto/update-group.dto';

@Injectable()
export class GroupsService {
  constructor(
    private prisma: PrismaService,
    private audit: AuditService,
  ) {}

  async create(userId: string, dto: CreateGroupDto) {
    const group = await this.prisma.group.create({
      data: {
        name: dto.name,
        location: dto.location,
        meetingDay: dto.meetingDay,
        weeklyContribution: dto.weeklyContribution ?? 0,
        sharePrice: dto.sharePrice ?? 10000,
        fineDefaultAmount: dto.fineDefaultAmount ?? 0,
        loanInterestRate: dto.loanInterestRate ?? 0,
        ownerId: userId,
        members: {
          create: {
            userId,
            name: 'Owner',
            role: "OWNER",
          },
        },
      },
      include: { members: true },
    });

    // Fill in the owner's real name from their user profile.
    const owner = await this.prisma.user.findUnique({ where: { id: userId } });
    if (owner) {
      await this.prisma.groupMember.updateMany({
        where: { groupId: group.id, userId },
        data: { name: owner.name, phone: owner.phone },
      });
    }

    await this.audit.log({
      userId,
      action: 'CREATE',
      entity: 'Group',
      entityId: group.id,
      groupId: group.id,
    });

    return this.findOne(group.id, userId);
  }

  async findAllForUser(userId: string) {
    return this.prisma.group.findMany({
      where: { members: { some: { userId, isActive: true } } },
      orderBy: { createdAt: 'desc' },
      include: {
        _count: { select: { members: true } },
      },
    });
  }

  async findOne(groupId: string, userId: string) {
    const group = await this.prisma.group.findUnique({
      where: { id: groupId },
      include: { members: { orderBy: { joinedAt: 'asc' } } },
    });
    if (!group) throw new NotFoundException('Group not found');

    const isMember = group.members.some((m) => m.userId === userId && m.isActive);
    if (!isMember) throw new ForbiddenException('You are not a member of this group');

    return group;
  }

  async update(groupId: string, userId: string, dto: UpdateGroupDto) {
    await this.findOne(groupId, userId);
    const group = await this.prisma.group.update({
      where: { id: groupId },
      data: { ...dto },
    });

    await this.audit.log({
      userId,
      action: 'UPDATE',
      entity: 'Group',
      entityId: groupId,
      groupId,
      metadata: dto as Record<string, any>,
    });

    return group;
  }
}
