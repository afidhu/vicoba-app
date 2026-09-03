import 'package:equatable/equatable.dart';

abstract class ContributionsEvent extends Equatable {
  const ContributionsEvent();

  @override
  List<Object?> get props => [];
}

class LoadContributionsEvent extends ContributionsEvent {
  final String groupId;
  final String? memberId;

  const LoadContributionsEvent({required this.groupId, this.memberId});

  @override
  List<Object?> get props => [groupId, memberId];
}

class RecordContributionEvent extends ContributionsEvent {
  final String groupId;
  final String memberId;
  final double? amount;
  final DateTime weekEnding;

  const RecordContributionEvent({
    required this.groupId,
    required this.memberId,
    this.amount,
    required this.weekEnding,
  });

  @override
  List<Object?> get props => [groupId, memberId, amount, weekEnding];
}
