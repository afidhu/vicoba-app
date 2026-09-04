import 'package:equatable/equatable.dart';

abstract class MembersEvent extends Equatable {
  const MembersEvent();

  @override
  List<Object?> get props => [];
}

class LoadMembersEvent extends MembersEvent {
  final String groupId;

  const LoadMembersEvent(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class LoadMemberDetailsEvent extends MembersEvent {
  final String groupId;
  final String memberId;

  const LoadMemberDetailsEvent({required this.groupId, required this.memberId});

  @override
  List<Object?> get props => [groupId, memberId];
}

class AddMemberEvent extends MembersEvent {
  final String groupId;
  final String name;
  final String? phone;
  final String role;
  final String? userId;
  final String? email;
  final String? password;

  const AddMemberEvent({
    required this.groupId,
    required this.name,
    this.phone,
    this.role = 'MEMBER',
    this.userId,
    this.email,
    this.password,
  });

  @override
  List<Object?> get props => [groupId, name, phone, role, userId, email, password];
}

class UpdateMemberEvent extends MembersEvent {
  final String groupId;
  final String memberId;
  final String? name;
  final String? phone;
  final String? role;
  final bool? isActive;

  const UpdateMemberEvent({
    required this.groupId,
    required this.memberId,
    this.name,
    this.phone,
    this.role,
    this.isActive,
  });

  @override
  List<Object?> get props => [groupId, memberId, name, phone, role, isActive];
}
