import 'package:equatable/equatable.dart';

class DashboardSummary extends Equatable {
  final DashboardGroupInfo group;
  final DashboardCounts counts;
  final DashboardTotals totals;
  final List<DashboardRecentTransaction> recentTransactions;

  const DashboardSummary({
    required this.group,
    required this.counts,
    required this.totals,
    required this.recentTransactions,
  });

  @override
  List<Object?> get props => [group, counts, totals, recentTransactions];
}

class DashboardGroupInfo extends Equatable {
  final String id;
  final String name;
  final String? location;
  final String? meetingDay;
  final double weeklyContribution;
  final double sharePrice;
  final double fineDefaultAmount;
  final double loanInterestRate;

  const DashboardGroupInfo({
    required this.id,
    required this.name,
    this.location,
    this.meetingDay,
    this.weeklyContribution = 0.0,
    this.sharePrice = 10000.0,
    this.fineDefaultAmount = 0.0,
    this.loanInterestRate = 0.0,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        location,
        meetingDay,
        weeklyContribution,
        sharePrice,
        fineDefaultAmount,
        loanInterestRate,
      ];
}

class DashboardCounts extends Equatable {
  final int totalMembers;
  final int activeMembers;
  final int activeLoans;

  const DashboardCounts({
    required this.totalMembers,
    required this.activeMembers,
    required this.activeLoans,
  });

  @override
  List<Object?> get props => [totalMembers, activeMembers, activeLoans];
}

class DashboardTotals extends Equatable {
  final double totalContributions;
  final double totalShareCapital;
  final double outstandingLoans;
  final double unpaidFines;
  final double totalExpenses;

  const DashboardTotals({
    required this.totalContributions,
    required this.totalShareCapital,
    required this.outstandingLoans,
    required this.unpaidFines,
    required this.totalExpenses,
  });

  @override
  List<Object?> get props => [
        totalContributions,
        totalShareCapital,
        outstandingLoans,
        unpaidFines,
        totalExpenses,
      ];
}

class DashboardRecentTransaction extends Equatable {
  final String id;
  final String? memberId;
  final String? memberName;
  final String type;
  final String direction;
  final double amount;
  final String? description;
  final DateTime createdAt;

  const DashboardRecentTransaction({
    required this.id,
    this.memberId,
    this.memberName,
    required this.type,
    required this.direction,
    required this.amount,
    this.description,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        memberId,
        memberName,
        type,
        direction,
        amount,
        description,
        createdAt,
      ];
}
