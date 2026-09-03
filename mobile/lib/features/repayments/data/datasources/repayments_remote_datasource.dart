import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/repayment_model.dart';

abstract class RepaymentsRemoteDataSource {
  Future<List<RepaymentModel>> getRepayments(String groupId, String loanId);
  Future<RepaymentModel> recordRepayment({
    required String groupId,
    required String loanId,
    required double amount,
  });
}

class RepaymentsRemoteDataSourceImpl implements RepaymentsRemoteDataSource {
  final Dio dio;

  RepaymentsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<RepaymentModel>> getRepayments(String groupId, String loanId) async {
    final response = await dio.get(ApiConstants.loanDetails(groupId, loanId));
    final list = (response.data['repayments'] as List?) ?? [];
    return list
        .map((r) => RepaymentModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<RepaymentModel> recordRepayment({
    required String groupId,
    required String loanId,
    required double amount,
  }) async {
    final response = await dio.post(
      ApiConstants.repayLoan(groupId, loanId),
      data: {'amount': amount},
    );
    final data = response.data is Map && response.data['repayment'] != null
        ? response.data['repayment']
        : response.data;
    return RepaymentModel.fromJson(data as Map<String, dynamic>);
  }
}
