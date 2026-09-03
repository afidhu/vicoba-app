import 'package:equatable/equatable.dart';

abstract class ReportsEvent extends Equatable {
  const ReportsEvent();
  @override
  List<Object?> get props => [];
}

class LoadGroupFinancialSummary extends ReportsEvent {
  final String groupId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadGroupFinancialSummary(this.groupId, {this.startDate, this.endDate});

  @override
  List<Object?> get props => [groupId, startDate, endDate];
}

class LoadMemberReport extends ReportsEvent {
  final String groupId;
  final String memberId;

  const LoadMemberReport(this.groupId, this.memberId);

  @override
  List<Object?> get props => [groupId, memberId];
}
