import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/contribution_model.dart';

abstract class ContributionsRemoteDataSource {
  Future<List<ContributionModel>> getContributions(
    String groupId, {
    String? memberId,
  });
  Future<ContributionModel> recordContribution(
    String groupId,
    Map<String, dynamic> data,
  );
}

class ContributionsRemoteDataSourceImpl implements ContributionsRemoteDataSource {
  final Dio dio;

  ContributionsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ContributionModel>> getContributions(
    String groupId, {
    String? memberId,
  }) async {
    final response = await dio.get(
      ApiConstants.contributions(groupId),
      queryParameters: memberId != null ? {'memberId': memberId} : null,
    );
    final List list = response.data as List;
    return list.map((c) => ContributionModel.fromJson(c as Map<String, dynamic>)).toList();
  }

  @override
  Future<ContributionModel> recordContribution(
    String groupId,
    Map<String, dynamic> data,
  ) async {
    final response = await dio.post(
      ApiConstants.contributions(groupId),
      data: data,
    );
    // Backend returns { contribution, transaction }.
    final body = response.data is Map && response.data['contribution'] != null
        ? response.data['contribution']
        : response.data;
    return ContributionModel.fromJson(body as Map<String, dynamic>);
  }
}
