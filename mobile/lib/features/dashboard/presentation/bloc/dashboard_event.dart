import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardSummaryEvent extends DashboardEvent {
  final String groupId;

  const LoadDashboardSummaryEvent(this.groupId);

  @override
  List<Object?> get props => [groupId];
}
