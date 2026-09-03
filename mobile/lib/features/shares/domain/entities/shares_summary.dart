import 'package:equatable/equatable.dart';

class SharesSummary extends Equatable {
  final double sharePrice;
  final int totalShares;
  final double totalShareCapital;
  final List<MemberShareBreakdown> breakdown;

  const SharesSummary({
    required this.sharePrice,
    required this.totalShares,
    required this.totalShareCapital,
    required this.breakdown,
  });

  @override
  List<Object?> get props => [sharePrice, totalShares, totalShareCapital, breakdown];
}

class MemberShareBreakdown extends Equatable {
  final String memberId;
  final String name;
  final int shareHoldings;
  final double shareValue;

  const MemberShareBreakdown({
    required this.memberId,
    required this.name,
    required this.shareHoldings,
    required this.shareValue,
  });

  @override
  List<Object?> get props => [memberId, name, shareHoldings, shareValue];
}
