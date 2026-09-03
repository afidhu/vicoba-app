import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { ExpensesService } from './expenses.service';
import { CreateExpenseDto } from './dto/create-expense.dto';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import { GroupRolesGuard } from '../common/guards/group-roles.guard';

@Controller('groups/:groupId/expenses')
@UseGuards(GroupRolesGuard)
export class ExpensesController {
  constructor(private expensesService: ExpensesService) {}

  @Post()
  @Roles("ADMIN", "TREASURER")
  create(
    @Param('groupId') groupId: string,
    @CurrentUser('id') userId: string,
    @Body() dto: CreateExpenseDto,
  ) {
    return this.expensesService.create(groupId, userId, dto);
  }

  @Get()
  findAll(@Param('groupId') groupId: string) {
    return this.expensesService.findAll(groupId);
  }
}
