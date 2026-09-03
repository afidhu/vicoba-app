import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { AuditService } from '../audit/audit.service';
import { CreateMeetingDto } from './dto/create-meeting.dto';
import { RecordAttendanceDto } from './dto/record-attendance.dto';

@Injectable()
export class MeetingsService {
  constructor(
    private prisma: PrismaService,
    private audit: AuditService,
  ) {}

  async create(groupId: string, actorUserId: string, dto: CreateMeetingDto) {
    const meeting = await this.prisma.meeting.create({
      data: {
        groupId,
        date: new Date(dto.date),
        title: dto.title,
        location: dto.location,
        notes: dto.notes,
      },
    });

    await this.audit.log({
      userId: actorUserId,
      action: 'CREATE',
      entity: 'Meeting',
      entityId: meeting.id,
      groupId,
    });

    return meeting;
  }

  findAll(groupId: string) {
    return this.prisma.meeting.findMany({
      where: { groupId },
      orderBy: { date: 'desc' },
      include: { _count: { select: { attendances: true } } },
    });
  }

  async findOne(groupId: string, meetingId: string) {
    const meeting = await this.prisma.meeting.findFirst({
      where: { id: meetingId, groupId },
      include: {
        attendances: {
          include: { member: { select: { id: true, name: true } } },
        },
      },
    });
    if (!meeting) throw new NotFoundException('Meeting not found');
    return meeting;
  }

  /**
   * Upserts attendance for a meeting. PDF 10.9 "automatic absence fines" is
   * intentionally out of scope here.
   */
  async recordAttendance(
    groupId: string,
    meetingId: string,
    actorUserId: string,
    dto: RecordAttendanceDto,
  ) {
    await this.findOne(groupId, meetingId);

    await this.prisma.$transaction(
      dto.items.map((item) =>
        this.prisma.meetingAttendance.upsert({
          where: {
            meetingId_memberId: { meetingId, memberId: item.memberId },
          },
          create: { meetingId, memberId: item.memberId, present: item.present },
          update: { present: item.present },
        }),
      ),
    );

    await this.audit.log({
      userId: actorUserId,
      action: 'RECORD_ATTENDANCE',
      entity: 'Meeting',
      entityId: meetingId,
      groupId,
      metadata: { count: dto.items.length },
    });

    return this.findOne(groupId, meetingId);
  }
}
