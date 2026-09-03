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
// import { GroupRole, LoanStatus } from '@prisma/client';
import { LoansService } from './loans.service';
import { CreateLoanDto } from './dto/create-loan.dto';
import { RepayLoanDto } from './dto/repay-loan.dto';
import { RequestLoanDto } from './dto/request-loan.dto';
import { ApproveLoanDto } from './dto/approve-loan.dto';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import { GroupRolesGuard } from '../common/guards/group-roles.guard';

@Controller('groups/:groupId/loans')
@UseGuards(GroupRolesGuard)
export class LoansController {
  constructor(private loansService: LoansService) {}

  @Post()
  @Roles("ADMIN", "TREASURER")
  create(
    @Param('groupId') groupId: string,
    @CurrentUser('id') userId: string,
    @Body() dto: CreateLoanDto,
  ) {
    return this.loansService.create(groupId, userId, dto);
  }

  /** Any active group member may request a loan (defaults to their own membership). */
  @Post('request')
  request(
    @Param('groupId') groupId: string,
    @CurrentUser('id') userId: string,
    @Body() dto: RequestLoanDto,
  ) {
    return this.loansService.request(groupId, userId, dto);
  }

  @Patch(':loanId/approve')
  @Roles('ADMIN', 'TREASURER')
  approve(
    @Param('groupId') groupId: string,
    @Param('loanId') loanId: string,
    @CurrentUser('id') userId: string,
    @Body() dto: ApproveLoanDto,
  ) {
    return this.loansService.approve(groupId, loanId, userId, dto);
  }

  @Patch(':loanId/reject')
  @Roles('ADMIN', 'TREASURER')
  reject(
    @Param('groupId') groupId: string,
    @Param('loanId') loanId: string,
    @CurrentUser('id') userId: string,
  ) {
    return this.loansService.reject(groupId, loanId, userId);
  }

  @Get()
  findAll(
    @Param('groupId') groupId: string,
    @Query('memberId') memberId?: string,
    @Query('status') status?: string,
  ) {
    return this.loansService.findAll(groupId, memberId, status);
  }

  @Get(':loanId')
  findOne(@Param('groupId') groupId: string, @Param('loanId') loanId: string) {
    return this.loansService.findOne(groupId, loanId);
  }

  @Post(':loanId/repayments')
  @Roles("ADMIN", "TREASURER")
  repay(
    @Param('groupId') groupId: string,
    @Param('loanId') loanId: string,
    @CurrentUser('id') userId: string,
    @Body() dto: RepayLoanDto,
  ) {
    return this.loansService.repay(groupId, loanId, userId, dto);
  }
}
