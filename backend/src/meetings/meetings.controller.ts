import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
// import { GroupRole } from '@prisma/client';
import { MeetingsService } from './meetings.service';
import { CreateMeetingDto } from './dto/create-meeting.dto';
import { RecordAttendanceDto } from './dto/record-attendance.dto';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import { GroupRolesGuard } from '../common/guards/group-roles.guard';

@Controller('groups/:groupId/meetings')
@UseGuards(GroupRolesGuard)
export class MeetingsController {
  constructor(private meetingsService: MeetingsService) {}

  @Post()
  @Roles("ADMIN", "SECRETARY")
  create(
    @Param('groupId') groupId: string,
    @CurrentUser('id') userId: string,
    @Body() dto: CreateMeetingDto,
  ) {
    return this.meetingsService.create(groupId, userId, dto);
  }

  @Get()
  findAll(@Param('groupId') groupId: string) {
    return this.meetingsService.findAll(groupId);
  }

  @Get(':meetingId')
  findOne(
    @Param('groupId') groupId: string,
    @Param('meetingId') meetingId: string,
  ) {
    return this.meetingsService.findOne(groupId, meetingId);
  }

  @Post(':meetingId/attendance')
  @Roles("ADMIN", "SECRETARY")
  recordAttendance(
    @Param('groupId') groupId: string,
    @Param('meetingId') meetingId: string,
    @CurrentUser('id') userId: string,
    @Body() dto: RecordAttendanceDto,
  ) {
    return this.meetingsService.recordAttendance(groupId, meetingId, userId, dto);
  }
}
