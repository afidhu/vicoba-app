import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/shares_summary_model.dart';

abstract class SharesRemoteDataSource {
  Future<SharesSummaryModel> getSharesSummary(String groupId);
  Future<Map<String, dynamic>> purchaseShares(
    String groupId,
    String memberId,
    int quantity,
  );
}

class SharesRemoteDataSourceImpl implements SharesRemoteDataSource {
  final Dio dio;

  SharesRemoteDataSourceImpl({required this.dio});

  @override
  Future<SharesSummaryModel> getSharesSummary(String groupId) async {
    final response = await dio.get(ApiConstants.sharesSummary(groupId));
    return SharesSummaryModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<Map<String, dynamic>> purchaseShares(
    String groupId,
    String memberId,
    int quantity,
  ) async {
    final response = await dio.post(
      ApiConstants.purchaseShares(groupId, memberId),
      data: {'quantity': quantity},
    );
    return response.data as Map<String, dynamic>;
  }
}
