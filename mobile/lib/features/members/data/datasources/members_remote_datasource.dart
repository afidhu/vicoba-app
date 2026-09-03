import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/member_model.dart';

abstract class MembersRemoteDataSource {
  Future<List<MemberModel>> getMembers(String groupId);
  Future<MemberModel> getMemberDetails(String groupId, String memberId);
  Future<MemberModel> addMember(String groupId, Map<String, dynamic> data);
  Future<MemberModel> updateMember(String groupId, String memberId, Map<String, dynamic> data);
}

class MembersRemoteDataSourceImpl implements MembersRemoteDataSource {
  final Dio dio;

  MembersRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<MemberModel>> getMembers(String groupId) async {
    final response = await dio.get(ApiConstants.members(groupId));
    final List list = response.data as List;
    return list.map((m) => MemberModel.fromJson(m as Map<String, dynamic>)).toList();
  }

  @override
  Future<MemberModel> getMemberDetails(String groupId, String memberId) async {
    final response = await dio.get(ApiConstants.memberDetails(groupId, memberId));
    return MemberModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MemberModel> addMember(String groupId, Map<String, dynamic> data) async {
    final response = await dio.post(ApiConstants.members(groupId), data: data);
    return MemberModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MemberModel> updateMember(
    String groupId,
    String memberId,
    Map<String, dynamic> data,
  ) async {
    final response = await dio.patch(ApiConstants.memberDetails(groupId, memberId), data: data);
    return MemberModel.fromJson(response.data as Map<String, dynamic>);
  }
}
