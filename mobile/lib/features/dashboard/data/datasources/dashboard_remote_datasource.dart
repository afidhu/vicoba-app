import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/dashboard_summary_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardSummaryModel> getGroupSummary(String groupId);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio dio;

  DashboardRemoteDataSourceImpl({required this.dio});

  @override
  Future<DashboardSummaryModel> getGroupSummary(String groupId) async {
    final response = await dio.get(ApiConstants.dashboard(groupId));
    return DashboardSummaryModel.fromJson(response.data as Map<String, dynamic>);
  }
}
