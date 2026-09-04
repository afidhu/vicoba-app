import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import { MembersService } from './members.service';
import { CreateMemberDto } from './dto/create-member.dto';
import { UpdateMemberDto } from './dto/update-member.dto';
import { PurchaseSharesDto } from './dto/purchase-shares.dto';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { GroupMembership } from '../common/decorators/group-membership.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import { GroupRolesGuard } from '../common/guards/group-roles.guard';
import { assertOwnRecordOrPrivileged, scopeMemberId } from '../common/utils/member-scope';

@Controller('groups/:groupId/members')
@UseGuards(GroupRolesGuard)
export class MembersController {
  constructor(private membersService: MembersService) {}

  @Post()
  @Roles('ADMIN', 'SECRETARY')
  create(
    @Param('groupId') groupId: string,
    @CurrentUser('id') userId: string,
    @Body() dto: CreateMemberDto,
  ) {
    return this.membersService.create(groupId, userId, dto);
  }

  @Get()
  findAll(
    @Param('groupId') groupId: string,
    @GroupMembership() membership: { id: string; role: string },
  ) {
    return this.membersService.findAll(groupId, scopeMemberId(membership));
  }

  @Get('shares-summary')
  async shareSummary(
    @Param('groupId') groupId: string,
    @GroupMembership() membership: { id: string; role: string },
  ) {
    return this.membersService.shareSummary(groupId, scopeMemberId(membership));
  }

  @Get(':memberId')
  async findOne(
    @Param('groupId') groupId: string,
    @Param('memberId') memberId: string,
    @GroupMembership() membership: { id: string; role: string },
  ) {
    assertOwnRecordOrPrivileged(membership, memberId);
    return this.membersService.findOne(groupId, memberId);
  }

  @Patch(':memberId')
  @Roles('ADMIN', 'SECRETARY')
  update(
    @Param('groupId') groupId: string,
    @Param('memberId') memberId: string,
    @CurrentUser('id') userId: string,
    @Body() dto: UpdateMemberDto,
  ) {
    return this.membersService.update(groupId, memberId, userId, dto);
  }

  @Post(':memberId/shares')
  @Roles('ADMIN', 'TREASURER')
  purchaseShares(
    @Param('groupId') groupId: string,
    @Param('memberId') memberId: string,
    @CurrentUser('id') userId: string,
    @Body() dto: PurchaseSharesDto,
  ) {
    return this.membersService.purchaseShares(groupId, memberId, userId, dto);
  }
}
