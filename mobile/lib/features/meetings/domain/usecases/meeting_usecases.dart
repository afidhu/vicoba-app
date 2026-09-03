import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/meeting.dart';
import '../repositories/meetings_repository.dart';

class GetMeetingsUseCase {
  final MeetingsRepository repository;
  GetMeetingsUseCase(this.repository);
  Future<Either<Failure, List<Meeting>>> call(String groupId) => repository.getMeetings(groupId);
}

class CreateMeetingUseCase {
  final MeetingsRepository repository;
  CreateMeetingUseCase(this.repository);
  Future<Either<Failure, Meeting>> call({
    required String groupId,
    required String title,
    required DateTime meetingDate,
    String? location,
    String? notes,
  }) => repository.createMeeting(
    groupId: groupId,
    title: title,
    meetingDate: meetingDate,
    location: location,
    notes: notes,
  );
}

class GetMeetingDetailsUseCase {
  final MeetingsRepository repository;
  GetMeetingDetailsUseCase(this.repository);
  Future<Either<Failure, Meeting>> call(String groupId, String meetingId) =>
      repository.getMeetingDetails(groupId, meetingId);
}

class RecordAttendanceUseCase {
  final MeetingsRepository repository;
  RecordAttendanceUseCase(this.repository);
  Future<Either<Failure, Meeting>> call(
    String groupId,
    String meetingId,
    List<Map<String, dynamic>> attendance,
  ) => repository.recordAttendance(groupId, meetingId, attendance);
}
