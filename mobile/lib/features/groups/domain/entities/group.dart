import 'package:equatable/equatable.dart';

class Group extends Equatable {
  final String id;
  final String name;
  final String? location;
  final String? meetingDay;
  final double weeklyContribution;
  final double sharePrice;
  final double fineDefaultAmount;
  final double loanInterestRate;
  final int memberCount;

  const Group({
    required this.id,
    required this.name,
    this.location,
    this.meetingDay,
    this.weeklyContribution = 0.0,
    this.sharePrice = 10000.0,
    this.fineDefaultAmount = 0.0,
    this.loanInterestRate = 0.0,
    this.memberCount = 0,
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
        memberCount,
      ];
}
