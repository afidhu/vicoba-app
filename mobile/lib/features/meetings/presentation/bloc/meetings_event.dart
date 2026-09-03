import 'package:equatable/equatable.dart';

abstract class MeetingsEvent extends Equatable {
  const MeetingsEvent();
  @override
  List<Object?> get props => [];
}

class LoadMeetings extends MeetingsEvent {
  final String groupId;
  const LoadMeetings(this.groupId);
  @override
  List<Object?> get props => [groupId];
}

class CreateMeeting extends MeetingsEvent {
  final String groupId;
  final String title;
  final DateTime meetingDate;
  final String? location;
  final String? notes;

  const CreateMeeting({
    required this.groupId,
    required this.title,
    required this.meetingDate,
    this.location,
    this.notes,
  });

  @override
  List<Object?> get props => [groupId, title, meetingDate, location, notes];
}

class LoadMeetingDetails extends MeetingsEvent {
  final String groupId;
  final String meetingId;
  const LoadMeetingDetails(this.groupId, this.meetingId);
  @override
  List<Object?> get props => [groupId, meetingId];
}

class RecordAttendance extends MeetingsEvent {
  final String meetingId;
  final List<Map<String, dynamic>> attendance;
  final String groupId;

  const RecordAttendance({
    required this.meetingId,
    required this.attendance,
    required this.groupId,
  });

  @override
  List<Object?> get props => [meetingId, attendance, groupId];
}
