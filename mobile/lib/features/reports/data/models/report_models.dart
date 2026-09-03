import '../../domain/entities/reports.dart';

double _d(dynamic v, [double def = 0]) {
  if (v == null) return def;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? def;
}

int _i(dynamic v, [int def = 0]) {
  if (v == null) return def;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? def;
}

class GroupFinancialSummaryModel extends GroupFinancialSummary {
  const GroupFinancialSummaryModel({
    required super.totalContributions,
    required super.totalShares,
    required super.totalFines,
    required super.totalRepayments,
    required super.totalDisbursements,
    required super.totalExpenses,
    required super.availableBalance,
  });

  /// Maps the backend `/reports/summary` shape:
  /// { contributions:{total}, fines:{totalUnpaid,totalPaid},
  ///   loans:{totalDisbursed,totalOutstanding}, expenses:{total},
  ///   cashFlow:{totalIn,totalOut,netMovement} }
  factory GroupFinancialSummaryModel.fromJson(Map<String, dynamic> json) {
    final contributions = (json['contributions'] as Map?) ?? {};
    final fines = (json['fines'] as Map?) ?? {};
    final loans = (json['loans'] as Map?) ?? {};
    final expenses = (json['expenses'] as Map?) ?? {};
    final cashFlow = (json['cashFlow'] as Map?) ?? {};

    final totalIn = _d(cashFlow['totalIn']);
    final contributionTotal = _d(contributions['total']);
    final finePaid = _d(fines['totalPaid']);

    return GroupFinancialSummaryModel(
      totalContributions: contributionTotal,
      totalShares: _d(json['shares']?['totalShareCapital']),
      totalFines: finePaid,
      totalRepayments:
          (totalIn - contributionTotal - finePaid).clamp(0, double.infinity).toDouble(),
      totalDisbursements: _d(loans['totalDisbursed']),
      totalExpenses: _d(expenses['total']),
      availableBalance: _d(cashFlow['netMovement']),
    );
  }
}

class MemberFinancialReportModel extends MemberFinancialReport {
  const MemberFinancialReportModel({
    required super.totalContributions,
    required super.totalShareValue,
    required super.totalShareQuantity,
    required super.totalFineOwed,
    required super.totalFinePaid,
    required super.fineBalance,
    required super.totalBorrowed,
    required super.totalRepaid,
    required super.outstandingLoanBalance,
  });

  factory MemberFinancialReportModel.fromJson(Map<String, dynamic> json) {
    final c = (json['contributions'] as Map?) ?? {};
    final s = (json['shares'] as Map?) ?? {};
    final f = (json['fines'] as Map?) ?? {};
    final l = (json['loans'] as Map?) ?? {};
    return MemberFinancialReportModel(
      totalContributions: _d(c['total']),
      totalShareValue: _d(s['totalValue']),
      totalShareQuantity: _i(s['totalQuantity']),
      totalFineOwed: _d(f['totalOwed']),
      totalFinePaid: _d(f['totalPaid']),
      fineBalance: _d(f['balance']),
      totalBorrowed: _d(l['totalBorrowed']),
      totalRepaid: _d(l['totalRepaid']),
      outstandingLoanBalance: _d(l['outstandingBalance']),
    );
  }
}
