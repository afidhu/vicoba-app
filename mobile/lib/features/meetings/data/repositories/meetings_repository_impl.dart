import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../domain/entities/meeting.dart';
import '../../domain/repositories/meetings_repository.dart';
import '../datasources/meetings_remote_datasource.dart';

class MeetingsRepositoryImpl implements MeetingsRepository {
  final MeetingsRemoteDataSource remoteDataSource;
  MeetingsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Meeting>>> getMeetings(String groupId) async {
    try {
      return Right(await remoteDataSource.getMeetings(groupId));
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, Meeting>> createMeeting({
    required String groupId,
    required String title,
    required DateTime meetingDate,
    String? location,
    String? notes,
  }) async {
    try {
      final meeting = await remoteDataSource.createMeeting(
        groupId: groupId,
        title: title,
        meetingDate: meetingDate.toIso8601String(),
        location: location,
        notes: notes,
      );
      return Right(meeting);
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, Meeting>> getMeetingDetails(String groupId, String meetingId) async {
    try {
      return Right(await remoteDataSource.getMeetingDetails(groupId, meetingId));
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, Meeting>> recordAttendance(
    String groupId,
    String meetingId,
    List<Map<String, dynamic>> attendance,
  ) async {
    try {
      return Right(await remoteDataSource.recordAttendance(groupId, meetingId, attendance));
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }
}
