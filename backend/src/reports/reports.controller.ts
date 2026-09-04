import { Controller, Get, Param, Query, UseGuards } from '@nestjs/common';
import { ReportsService } from './reports.service';
import { Roles } from '../common/decorators/roles.decorator';
import { GroupRolesGuard } from '../common/guards/group-roles.guard';

@Controller('groups/:groupId/reports')
@UseGuards(GroupRolesGuard)
@Roles('ADMIN', 'TREASURER', 'SECRETARY')
export class ReportsController {
  constructor(private reportsService: ReportsService) {}

  @Get('contributions')
  contributions(
    @Param('groupId') groupId: string,
    @Query('from') from?: string,
    @Query('to') to?: string,
  ) {
    return this.reportsService.contributionsReport(groupId, { from, to });
  }

  @Get('shares')
  shares(@Param('groupId') groupId: string) {
    return this.reportsService.sharesReport(groupId);
  }

  @Get('fines')
  fines(
    @Param('groupId') groupId: string,
    @Query('from') from?: string,
    @Query('to') to?: string,
  ) {
    return this.reportsService.finesReport(groupId, { from, to });
  }

  @Get('loans')
  loans(
    @Param('groupId') groupId: string,
    @Query('from') from?: string,
    @Query('to') to?: string,
  ) {
    return this.reportsService.loansReport(groupId, { from, to });
  }

  @Get('expenses')
  expenses(
    @Param('groupId') groupId: string,
    @Query('from') from?: string,
    @Query('to') to?: string,
  ) {
    return this.reportsService.expensesReport(groupId, { from, to });
  }

  @Get('transactions')
  transactions(
    @Param('groupId') groupId: string,
    @Query('from') from?: string,
    @Query('to') to?: string,
  ) {
    return this.reportsService.transactionsReport(groupId, { from, to });
  }

  @Get('summary')
  summary(
    @Param('groupId') groupId: string,
    @Query('from') from?: string,
    @Query('to') to?: string,
  ) {
    return this.reportsService.financialSummary(groupId, { from, to });
  }
}
