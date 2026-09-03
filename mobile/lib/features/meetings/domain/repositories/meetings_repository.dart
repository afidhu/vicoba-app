import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/meeting.dart';

abstract class MeetingsRepository {
  Future<Either<Failure, List<Meeting>>> getMeetings(String groupId);
  Future<Either<Failure, Meeting>> createMeeting({
    required String groupId,
    required String title,
    required DateTime meetingDate,
    String? location,
    String? notes,
  });
  Future<Either<Failure, Meeting>> getMeetingDetails(String groupId, String meetingId);
  Future<Either<Failure, Meeting>> recordAttendance(
    String groupId,
    String meetingId,
    List<Map<String, dynamic>> attendance,
  );
}
