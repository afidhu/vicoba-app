import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/meeting_model.dart';

abstract class MeetingsRemoteDataSource {
  Future<List<MeetingModel>> getMeetings(String groupId);
  Future<MeetingModel> createMeeting({
    required String groupId,
    required String title,
    required String meetingDate,
    String? location,
    String? notes,
  });
  Future<MeetingModel> getMeetingDetails(String groupId, String meetingId);
  Future<MeetingModel> recordAttendance(
    String groupId,
    String meetingId,
    List<Map<String, dynamic>> attendance,
  );
}

class MeetingsRemoteDataSourceImpl implements MeetingsRemoteDataSource {
  final Dio dio;
  MeetingsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<MeetingModel>> getMeetings(String groupId) async {
    final response = await dio.get(ApiConstants.meetings(groupId));
    return (response.data as List)
        .map((m) => MeetingModel.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MeetingModel> createMeeting({
    required String groupId,
    required String title,
    required String meetingDate,
    String? location,
    String? notes,
  }) async {
    final response = await dio.post(
      ApiConstants.meetings(groupId),
      data: {
        'date': meetingDate,
        'title': title,
        if (location != null && location.isNotEmpty) 'location': location,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
    return MeetingModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MeetingModel> getMeetingDetails(String groupId, String meetingId) async {
    final response = await dio.get(ApiConstants.meetingDetails(groupId, meetingId));
    return MeetingModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MeetingModel> recordAttendance(
    String groupId,
    String meetingId,
    List<Map<String, dynamic>> attendance,
  ) async {
    final response = await dio.post(
      ApiConstants.meetingAttendance(groupId, meetingId),
      data: {'items': attendance},
    );
    return MeetingModel.fromJson(response.data as Map<String, dynamic>);
  }
}
