import '../../domain/entities/meeting.dart';

class MeetingModel extends Meeting {
  const MeetingModel({
    required super.id,
    required super.groupId,
    required super.title,
    required super.meetingDate,
    super.location,
    super.notes,
    required super.createdBy,
    super.attendance,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    final rawAttendance = json['attendances'] ?? json['attendance'];
    return MeetingModel(
      id: json['id'] ?? '',
      groupId: json['groupId'] ?? '',
      title: (json['title'] as String?)?.isNotEmpty == true
          ? json['title']
          : 'Group meeting',
      meetingDate: DateTime.tryParse(
              (json['date'] ?? json['meetingDate'] ?? '').toString()) ??
          DateTime.now(),
      location: json['location'],
      notes: json['notes'],
      createdBy: json['createdBy'] ?? '',
      attendance: rawAttendance is List
          ? rawAttendance
              .map((a) => MeetingAttendanceModel.fromJson(a as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}

class MeetingAttendanceModel extends MeetingAttendance {
  const MeetingAttendanceModel({
    required super.id,
    required super.meetingId,
    required super.memberId,
    required super.status,
    super.notes,
    super.memberName,
  });

  factory MeetingAttendanceModel.fromJson(Map<String, dynamic> json) {
    String status;
    if (json['status'] != null) {
      status = json['status'];
    } else {
      status = (json['present'] == true) ? 'PRESENT' : 'ABSENT';
    }
    return MeetingAttendanceModel(
      id: json['id'] ?? '',
      meetingId: json['meetingId'] ?? '',
      memberId: json['memberId'] ?? '',
      status: status,
      notes: json['notes'],
      memberName: json['member']?['name'],
    );
  }
}
