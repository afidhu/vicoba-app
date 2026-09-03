import { Controller, Get, Param, Query, UseGuards } from '@nestjs/common';
// import { TransactionType } from '@prisma/client';
import { TransactionsService } from './transactions.service';
import { GroupRolesGuard } from '../common/guards/group-roles.guard';

@Controller('groups/:groupId/transactions')
@UseGuards(GroupRolesGuard)
export class TransactionsController {
  constructor(private transactionsService: TransactionsService) {}

  @Get()
  findAll(
    @Param('groupId') groupId: string,
    @Query('memberId') memberId?: string,
    @Query('type') type?: string,
    @Query('from') from?: string,
    @Query('to') to?: string,
  ) {
    return this.transactionsService.findAll(groupId, { memberId, type, from, to });
  }

  @Get('audit-log')
  auditLog(@Param('groupId') groupId: string) {
    return this.transactionsService.auditLog(groupId);
  }
}
