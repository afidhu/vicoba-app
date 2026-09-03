import 'package:equatable/equatable.dart';
import '../../domain/entities/group.dart';

abstract class GroupsState extends Equatable {
  const GroupsState();

  @override
  List<Object?> get props => [];
}

class GroupsInitial extends GroupsState {}

class GroupsLoading extends GroupsState {}

class GroupsLoaded extends GroupsState {
  final List<Group> groups;
  final Group? activeGroup;

  const GroupsLoaded({required this.groups, this.activeGroup});

  @override
  List<Object?> get props => [groups, activeGroup];
}

class GroupDetailsLoaded extends GroupsState {
  final Group group;

  const GroupDetailsLoaded(this.group);

  @override
  List<Object?> get props => [group];
}

class GroupOperationSuccess extends GroupsState {
  final String message;
  final Group? createdGroup;

  const GroupOperationSuccess(this.message, {this.createdGroup});

  @override
  List<Object?> get props => [message, createdGroup];
}

class GroupsError extends GroupsState {
  final String message;

  const GroupsError(this.message);

  @override
  List<Object?> get props => [message];
}
