import { Body, Controller, Get, Param, Post, Query, UseGuards } from '@nestjs/common';
import { ContributionsService } from './contributions.service';
import { CreateContributionDto } from './dto/create-contribution.dto';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { GroupMembership } from '../common/decorators/group-membership.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import { GroupRolesGuard } from '../common/guards/group-roles.guard';
import { scopeMemberId } from '../common/utils/member-scope';

@Controller('groups/:groupId/contributions')
@UseGuards(GroupRolesGuard)
export class ContributionsController {
  constructor(private contributionsService: ContributionsService) {}

  @Post()
  @Roles("ADMIN", "TREASURER")
  create(
    @Param('groupId') groupId: string,
    @CurrentUser('id') userId: string,
    @Body() dto: CreateContributionDto,
  ) {
    return this.contributionsService.create(groupId, userId, dto);
  }

  @Get()
  findAll(
    @Param('groupId') groupId: string,
    @Query('memberId') memberId: string | undefined,
    @GroupMembership() membership: { id: string; role: string },
  ) {
    return this.contributionsService.findAll(groupId, scopeMemberId(membership, memberId));
  }
}
