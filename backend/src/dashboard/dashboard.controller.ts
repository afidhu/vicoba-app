import { Controller, Get, Param, UseGuards } from '@nestjs/common';
import { DashboardService } from './dashboard.service';
import { GroupRolesGuard } from '../common/guards/group-roles.guard';

@Controller('groups/:groupId/dashboard')
@UseGuards(GroupRolesGuard)
export class DashboardController {
  constructor(private dashboardService: DashboardService) {}

  @Get()
  getSummary(@Param('groupId') groupId: string) {
    return this.dashboardService.getSummary(groupId);
  }
}
