import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/group_model.dart';

abstract class GroupsRemoteDataSource {
  Future<List<GroupModel>> getGroups();
  Future<GroupModel> getGroupDetails(String groupId);
  Future<GroupModel> createGroup(Map<String, dynamic> data);
  Future<GroupModel> updateGroup(String groupId, Map<String, dynamic> data);
}

class GroupsRemoteDataSourceImpl implements GroupsRemoteDataSource {
  final Dio dio;

  GroupsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<GroupModel>> getGroups() async {
    final response = await dio.get(ApiConstants.groups);
    final List list = response.data as List;
    return list.map((g) => GroupModel.fromJson(g as Map<String, dynamic>)).toList();
  }

  @override
  Future<GroupModel> getGroupDetails(String groupId) async {
    final response = await dio.get(ApiConstants.groupDetails(groupId));
    return GroupModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<GroupModel> createGroup(Map<String, dynamic> data) async {
    final response = await dio.post(ApiConstants.groups, data: data);
    return GroupModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<GroupModel> updateGroup(String groupId, Map<String, dynamic> data) async {
    final response = await dio.patch(ApiConstants.groupDetails(groupId), data: data);
    return GroupModel.fromJson(response.data as Map<String, dynamic>);
  }
}
