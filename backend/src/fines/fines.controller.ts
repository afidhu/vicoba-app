import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { FinesService } from './fines.service';
import { CreateFineDto } from './dto/create-fine.dto';
import { UpdateFineStatusDto } from './dto/update-fine-status.dto';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import { GroupRolesGuard } from '../common/guards/group-roles.guard';

@Controller('groups/:groupId/fines')
@UseGuards(GroupRolesGuard)
export class FinesController {
  constructor(private finesService: FinesService) {}

  @Post()
  @Roles("ADMIN", "TREASURER", "SECRETARY")
  create(
    @Param('groupId') groupId: string,
    @CurrentUser('id') userId: string,
    @Body() dto: CreateFineDto,
  ) {
    return this.finesService.create(groupId, userId, dto);
  }

  @Get()
  findAll(
    @Param('groupId') groupId: string,
    @Query('memberId') memberId?: string,
    @Query('status') status?: string,
  ) {
    return this.finesService.findAll(groupId, memberId, status);
  }

  @Patch(':fineId/status')
  @Roles("ADMIN", "TREASURER")
  updateStatus(
    @Param('groupId') groupId: string,
    @Param('fineId') fineId: string,
    @CurrentUser('id') userId: string,
    @Body() dto: UpdateFineStatusDto,
  ) {
    return this.finesService.updateStatus(groupId, fineId, userId, dto);
  }
}
