import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { AuditService } from '../audit/audit.service';
import { CreateContributionDto } from './dto/create-contribution.dto';

@Injectable()
export class ContributionsService {
  constructor(
    private prisma: PrismaService,
    private audit: AuditService,
  ) {}

  async create(groupId: string, actorUserId: string, dto: CreateContributionDto) {
    const [member, group] = await Promise.all([
      this.prisma.groupMember.findFirst({ where: { id: dto.memberId, groupId } }),
      this.prisma.group.findUnique({ where: { id: groupId } }),
    ]);
    if (!member) throw new NotFoundException('Member not found in this group');
    if (!group) throw new NotFoundException('Group not found');
    if (!member.isActive) {
      throw new BadRequestException('Cannot record a contribution for an inactive member');
    }

    const amount = dto.amount ?? Number(group.weeklyContribution);
    if (!amount || amount <= 0) {
      throw new BadRequestException(
        'A contribution amount is required (the group has no default weekly contribution set)',
      );
    }

    const [contribution, transaction] = await this.prisma.$transaction([
      this.prisma.contribution.create({
        data: {
          groupId,
          memberId: dto.memberId,
          amount,
          weekEnding: new Date(dto.weekEnding),
        },
      }),
      this.prisma.transaction.create({
        data: {
          groupId,
          memberId: dto.memberId,
          type: "CONTRIBUTION",
          direction: "IN",
          amount,
          description: `Weekly contribution (week ending ${dto.weekEnding})`,
        },
      }),
    ]);

    await this.audit.log({
      userId: actorUserId,
      action: 'CREATE',
      entity: 'Contribution',
      entityId: contribution.id,
      groupId,
      metadata: { memberId: dto.memberId, amount },
    });

    return { contribution, transaction };
  }

  findAll(groupId: string, memberId?: string) {
    return this.prisma.contribution.findMany({
      where: { groupId, ...(memberId ? { memberId } : {}) },
      include: { member: { select: { id: true, name: true } } },
      orderBy: { weekEnding: 'desc' },
    });
  }
}
