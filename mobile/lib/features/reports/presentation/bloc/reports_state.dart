import 'package:equatable/equatable.dart';
import '../../domain/entities/reports.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();
  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {}
class ReportsLoading extends ReportsState {}

class GroupFinancialSummaryLoaded extends ReportsState {
  final GroupFinancialSummary summary;
  const GroupFinancialSummaryLoaded(this.summary);
  @override
  List<Object?> get props => [summary];
}

class MemberReportLoaded extends ReportsState {
  final MemberFinancialReport report;
  const MemberReportLoaded(this.report);
  @override
  List<Object?> get props => [report];
}

class ReportsError extends ReportsState {
  final String message;
  const ReportsError(this.message);
  @override
  List<Object?> get props => [message];
}
