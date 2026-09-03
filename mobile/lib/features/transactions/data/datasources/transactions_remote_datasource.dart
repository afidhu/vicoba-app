import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/transaction_model.dart';

abstract class TransactionsRemoteDataSource {
  Future<List<TransactionModel>> getTransactions(
    String groupId, {
    String? memberId,
    String? type,
  });
}

class TransactionsRemoteDataSourceImpl implements TransactionsRemoteDataSource {
  final Dio dio;
  TransactionsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<TransactionModel>> getTransactions(
    String groupId, {
    String? memberId,
    String? type,
  }) async {
    final response = await dio.get(
      ApiConstants.transactions(groupId),
      queryParameters: {
        if (memberId != null) 'memberId': memberId,
        if (type != null) 'type': type,
      },
    );
    return (response.data as List)
        .map((t) => TransactionModel.fromJson(t as Map<String, dynamic>))
        .toList();
  }
}
