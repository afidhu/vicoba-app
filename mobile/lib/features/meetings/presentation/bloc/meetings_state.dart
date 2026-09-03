import 'package:equatable/equatable.dart';
import '../../domain/entities/meeting.dart';

abstract class MeetingsState extends Equatable {
  const MeetingsState();
  @override
  List<Object?> get props => [];
}

class MeetingsInitial extends MeetingsState {}
class MeetingsLoading extends MeetingsState {}

class MeetingsLoaded extends MeetingsState {
  final List<Meeting> meetings;
  const MeetingsLoaded(this.meetings);
  @override
  List<Object?> get props => [meetings];
}

class MeetingDetailsLoaded extends MeetingsState {
  final Meeting meeting;
  const MeetingDetailsLoaded(this.meeting);
  @override
  List<Object?> get props => [meeting];
}

class MeetingsError extends MeetingsState {
  final String message;
  const MeetingsError(this.message);
  @override
  List<Object?> get props => [message];
}

class MeetingActionSuccess extends MeetingsState {}
