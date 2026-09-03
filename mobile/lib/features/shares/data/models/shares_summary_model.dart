import '../../domain/entities/shares_summary.dart';

class SharesSummaryModel extends SharesSummary {
  const SharesSummaryModel({
    required super.sharePrice,
    required super.totalShares,
    required super.totalShareCapital,
    required super.breakdown,
  });

  factory SharesSummaryModel.fromJson(Map<String, dynamic> json) {
    final breakdownList = json['breakdown'] as List? ?? [];

    return SharesSummaryModel(
      sharePrice: _toDouble(json['sharePrice'], defaultValue: 10000.0),
      totalShares: _toInt(json['totalShares']),
      totalShareCapital: _toDouble(json['totalShareCapital']),
      breakdown: breakdownList.map((item) {
        final map = item as Map<String, dynamic>;
        return MemberShareBreakdown(
          memberId: map['memberId'] ?? '',
          name: map['name'] ?? '',
          shareHoldings: _toInt(map['shareHoldings']),
          shareValue: _toDouble(map['shareValue']),
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
