import '../../domain/entities/dashboard_summary.dart';

class DashboardSummaryModel extends DashboardSummary {
  const DashboardSummaryModel({
    required super.group,
    required super.counts,
    required super.totals,
    required super.recentTransactions,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    final groupJson = json['group'] as Map<String, dynamic>? ?? {};
    final countsJson = json['counts'] as Map<String, dynamic>? ?? {};
    final totalsJson = json['totals'] as Map<String, dynamic>? ?? {};
    final recentTxList = json['recentTransactions'] as List? ?? [];

    return DashboardSummaryModel(
      group: DashboardGroupInfo(
        id: groupJson['id'] ?? '',
        name: groupJson['name'] ?? '',
        location: groupJson['location'],
        meetingDay: groupJson['meetingDay'],
        weeklyContribution: _toDouble(groupJson['weeklyContribution']),
        sharePrice: _toDouble(groupJson['sharePrice'], defaultValue: 10000.0),
        fineDefaultAmount: _toDouble(groupJson['fineDefaultAmount']),
        loanInterestRate: _toDouble(groupJson['loanInterestRate']),
      ),
      counts: DashboardCounts(
        totalMembers: _toInt(countsJson['totalMembers']),
        activeMembers: _toInt(countsJson['activeMembers']),
        activeLoans: _toInt(countsJson['activeLoans']),
      ),
      totals: DashboardTotals(
        totalContributions: _toDouble(totalsJson['totalContributions']),
        totalShareCapital: _toDouble(totalsJson['totalShareCapital']),
        outstandingLoans: _toDouble(totalsJson['outstandingLoans']),
        unpaidFines: _toDouble(totalsJson['unpaidFines']),
        totalExpenses: _toDouble(totalsJson['totalExpenses']),
      ),
      recentTransactions: recentTxList.map((tx) {
        final txMap = tx as Map<String, dynamic>;
        final memberMap = txMap['member'] as Map<String, dynamic>?;
        return DashboardRecentTransaction(
          id: txMap['id'] ?? '',
          memberId: txMap['memberId'],
          memberName: memberMap != null ? memberMap['name'] : null,
          type: txMap['type'] ?? '',
          direction: txMap['direction'] ?? 'IN',
          amount: _toDouble(txMap['amount']),
          description: txMap['description'],
          createdAt: txMap['createdAt'] != null
              ? DateTime.parse(txMap['createdAt'])
              : DateTime.now(),
        );
      }).toList(),
    );
  }

  static double _toDouble(dynamic val, {double defaultValue = 0.0}) {
    if (val == null) return defaultValue;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? defaultValue;
  }

  static int _toInt(dynamic val, {int defaultValue = 0}) {
    if (val == null) return defaultValue;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString()) ?? defaultValue;
  }
}
