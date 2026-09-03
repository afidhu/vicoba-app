import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
// import { GroupRole } from '@prisma/client';
import { MembersService } from './members.service';
import { CreateMemberDto } from './dto/create-member.dto';
import { UpdateMemberDto } from './dto/update-member.dto';
import { PurchaseSharesDto } from './dto/purchase-shares.dto';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import { GroupRolesGuard } from '../common/guards/group-roles.guard';

@Controller('groups/:groupId/members')
@UseGuards(GroupRolesGuard)
export class MembersController {
  constructor(private membersService: MembersService) {}

  @Post()
  // @Roles(GroupRole.ADMIN, GroupRole.SECRETARY)
  create(
    @Param('groupId') groupId: string,
    @CurrentUser('id') userId: string,
    @Body() dto: CreateMemberDto,
  ) {
    return this.membersService.create(groupId, userId, dto);
  }

  @Get()
  findAll(@Param('groupId') groupId: string) {
    return this.membersService.findAll(groupId);
  }

  @Get('shares-summary')
  shareSummary(@Param('groupId') groupId: string) {
    return this.membersService.shareSummary(groupId);
  }

  @Get(':memberId')
  findOne(@Param('groupId') groupId: string, @Param('memberId') memberId: string) {
    return this.membersService.findOne(groupId, memberId);
  }

  @Patch(':memberId')
  // @Roles(GroupRole.ADMIN, GroupRole.SECRETARY)
  update(
    @Param('groupId') groupId: string,
    @Param('memberId') memberId: string,
    @CurrentUser('id') userId: string,
    @Body() dto: UpdateMemberDto,
  ) {
    return this.membersService.update(groupId, memberId, userId, dto);
  }

  @Post(':memberId/shares')
  // @Roles(GroupRole.ADMIN, GroupRole.TREASURER)
  purchaseShares(
    @Param('groupId') groupId: string,
    @Param('memberId') memberId: string,
    @CurrentUser('id') userId: string,
    @Body() dto: PurchaseSharesDto,
  ) {
    return this.membersService.purchaseShares(groupId, memberId, userId, dto);
  }
}
