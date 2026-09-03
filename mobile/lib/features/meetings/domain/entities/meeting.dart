import 'package:equatable/equatable.dart';

class Meeting extends Equatable {
  final String id;
  final String groupId;
  final String title;
  final DateTime meetingDate;
  final String? location;
  final String? notes;
  final String createdBy;
  final List<MeetingAttendance>? attendance;

  const Meeting({
    required this.id,
    required this.groupId,
    required this.title,
    required this.meetingDate,
    this.location,
    this.notes,
    required this.createdBy,
    this.attendance,
  });

  @override
  List<Object?> get props => [id, groupId, title, meetingDate, location, notes, createdBy, attendance];
}

class MeetingAttendance extends Equatable {
  final String id;
  final String meetingId;
  final String memberId;
  final String status;
  final String? notes;
  final String? memberName;

  const MeetingAttendance({
    required this.id,
    required this.meetingId,
    required this.memberId,
    required this.status,
    this.notes,
    this.memberName,
  });

  @override
  List<Object?> get props => [id, meetingId, memberId, status, notes, memberName];
}
