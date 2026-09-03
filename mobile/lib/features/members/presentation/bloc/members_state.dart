import 'package:equatable/equatable.dart';
import '../../domain/entities/member.dart';

abstract class MembersState extends Equatable {
  const MembersState();

  @override
  List<Object?> get props => [];
}

class MembersInitial extends MembersState {}

class MembersLoading extends MembersState {}

class MembersLoaded extends MembersState {
  final List<Member> members;

  const MembersLoaded(this.members);

  @override
  List<Object?> get props => [members];
}

class MemberDetailsLoaded extends MembersState {
  final Member member;

  const MemberDetailsLoaded(this.member);

  @override
  List<Object?> get props => [member];
}

class MemberOperationSuccess extends MembersState {
  final String message;
  final Member? member;

  const MemberOperationSuccess(this.message, {this.member});

  @override
  List<Object?> get props => [message, member];
}

class MembersError extends MembersState {
  final String message;

  const MembersError(this.message);

  @override
  List<Object?> get props => [message];
}
