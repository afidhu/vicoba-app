import 'package:equatable/equatable.dart';

abstract class GroupsEvent extends Equatable {
  const GroupsEvent();

  @override
  List<Object?> get props => [];
}

class LoadGroupsEvent extends GroupsEvent {}

class LoadGroupDetailsEvent extends GroupsEvent {
  final String groupId;

  const LoadGroupDetailsEvent(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class CreateGroupEvent extends GroupsEvent {
  final String name;
  final String? location;
  final String? meetingDay;
  final double? weeklyContribution;
  final double? sharePrice;
  final double? fineDefaultAmount;
  final double? loanInterestRate;

  const CreateGroupEvent({
    required this.name,
    this.location,
    this.meetingDay,
    this.weeklyContribution,
    this.sharePrice,
    this.fineDefaultAmount,
    this.loanInterestRate,
  });

  @override
  List<Object?> get props => [
        name,
        location,
        meetingDay,
        weeklyContribution,
        sharePrice,
        fineDefaultAmount,
        loanInterestRate,
      ];
}

class SelectActiveGroupEvent extends GroupsEvent {
  final String groupId;
  final String groupName;

  const SelectActiveGroupEvent({required this.groupId, required this.groupName});

  @override
  List<Object?> get props => [groupId, groupName];
}
