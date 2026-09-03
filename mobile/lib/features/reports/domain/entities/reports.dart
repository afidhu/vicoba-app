import 'package:equatable/equatable.dart';

class GroupFinancialSummary extends Equatable {
  final double totalContributions;
  final double totalShares;
  final double totalFines;
  final double totalRepayments;
  final double totalDisbursements;
  final double totalExpenses;
  final double availableBalance;

  const GroupFinancialSummary({
    required this.totalContributions,
    required this.totalShares,
    required this.totalFines,
    required this.totalRepayments,
    required this.totalDisbursements,
    required this.totalExpenses,
    required this.availableBalance,
  });

  @override
  List<Object?> get props => [totalContributions, totalShares, totalFines, totalRepayments, totalDisbursements, totalExpenses, availableBalance];
}

class MemberFinancialReport extends Equatable {
  final double totalContributions;
  final double totalShareValue;
  final int totalShareQuantity;
  final double totalFineOwed;
  final double totalFinePaid;
  final double fineBalance;
  final double totalBorrowed;
  final double totalRepaid;
  final double outstandingLoanBalance;

  const MemberFinancialReport({
    required this.totalContributions,
    required this.totalShareValue,
    required this.totalShareQuantity,
    required this.totalFineOwed,
    required this.totalFinePaid,
    required this.fineBalance,
    required this.totalBorrowed,
    required this.totalRepaid,
    required this.outstandingLoanBalance,
  });

  @override
  List<Object?> get props => [totalContributions, totalShareValue, totalShareQuantity, totalFineOwed, totalFinePaid, fineBalance, totalBorrowed, totalRepaid, outstandingLoanBalance];
}
