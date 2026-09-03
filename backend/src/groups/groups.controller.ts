import { Body, Controller, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { GroupsService } from './groups.service';
import { CreateGroupDto } from './dto/create-group.dto';
import { UpdateGroupDto } from './dto/update-group.dto';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import { GroupRolesGuard } from '../common/guards/group-roles.guard';
// import { GroupRole } from '@prisma/client';

@Controller('groups')
export class GroupsController {
  constructor(private groupsService: GroupsService) {}

  @Post()
  create(@CurrentUser('id') userId: string, @Body() dto: CreateGroupDto) {
    return this.groupsService.create(userId, dto);
  }

  @Get()
  findMine(@CurrentUser('id') userId: string) {
    return this.groupsService.findAllForUser(userId);
  }

  @Get(':groupId')
  @UseGuards(GroupRolesGuard)
  findOne(@Param('groupId') groupId: string, @CurrentUser('id') userId: string) {
    return this.groupsService.findOne(groupId, userId);
  }

  @Patch(':groupId')
  @UseGuards(GroupRolesGuard)
  @Roles("ADMIN")
  update(
    @Param('groupId') groupId: string,
    @CurrentUser('id') userId: string,
    @Body() dto: UpdateGroupDto,
  ) {
    return this.groupsService.update(groupId, userId, dto);
  }
}
