import { Body, Controller, Get, Param, Post, Query, UseGuards } from '@nestjs/common';
// import { TransactionType } from '@prisma/client';
import { TransactionsService } from './transactions.service';
import { GroupMembership } from '../common/decorators/group-membership.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import { GroupRolesGuard } from '../common/guards/group-roles.guard';
import { scopeMemberId } from '../common/utils/member-scope';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { CreateTransactionDto } from './dto/create-transaction.dto';

@Controller('groups/:groupId/transactions')
@UseGuards(GroupRolesGuard)
export class TransactionsController {
  constructor(private transactionsService: TransactionsService) {}

  @Post()
  @Roles('ADMIN', 'TREASURER')
  createOther(
    @Param('groupId') groupId: string,
    @CurrentUser('id') userId: string,
    @Body() dto: CreateTransactionDto,
  ) {
    return this.transactionsService.createOther(groupId, userId, dto);
  }

  @Get()
  findAll(
    @Param('groupId') groupId: string,
    @Query('memberId') memberId: string | undefined,
    @Query('type') type: string | undefined,
    @Query('from') from: string | undefined,
    @Query('to') to: string | undefined,
    @GroupMembership() membership: { id: string; role: string },
  ) {
    return this.transactionsService.findAll(groupId, {
      memberId: scopeMemberId(membership, memberId),
      type,
      from,
      to,
    });
  }

  @Get('audit-log')
  @Roles('ADMIN')
  auditLog(@Param('groupId') groupId: string) {
    return this.transactionsService.auditLog(groupId);
  }
}
