import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { APP_GUARD } from '@nestjs/core';
import { PrismaModule } from './prisma/prisma.module';
import { AuditModule } from './audit/audit.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { GroupsModule } from './groups/groups.module';
import { MembersModule } from './members/members.module';
import { ContributionsModule } from './contributions/contributions.module';
import { FinesModule } from './fines/fines.module';
import { LoansModule } from './loans/loans.module';
import { ExpensesModule } from './expenses/expenses.module';
import { MeetingsModule } from './meetings/meetings.module';
import { TransactionsModule } from './transactions/transactions.module';
import { DashboardModule } from './dashboard/dashboard.module';
import { ReportsModule } from './reports/reports.module';
import { JwtAuthGuard } from './common/guards/jwt-auth.guard';
import { GroupRolesGuard } from './common/guards/group-roles.guard';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    AuditModule,
    AuthModule,
    UsersModule,
    GroupsModule,
    MembersModule,
    ContributionsModule,
    FinesModule,
    LoansModule,
    ExpensesModule,
    MeetingsModule,
    TransactionsModule,
    DashboardModule,
    ReportsModule,
  ],
  providers: [
    { provide: APP_GUARD, useClass: JwtAuthGuard },
    GroupRolesGuard,
  ],
})
export class AppModule {}
