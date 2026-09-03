import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/expense_model.dart';

abstract class ExpensesRemoteDataSource {
  Future<List<ExpenseModel>> getExpenses(String groupId);
  Future<ExpenseModel> recordExpense({
    required String groupId,
    required String description,
    required double amount,
    String? expenseDate,
    String? category,
    String? notes,
  });
}

class ExpensesRemoteDataSourceImpl implements ExpensesRemoteDataSource {
  final Dio dio;

  ExpensesRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ExpenseModel>> getExpenses(String groupId) async {
    final response = await dio.get(ApiConstants.expenses(groupId));
    return (response.data as List)
        .map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ExpenseModel> recordExpense({
    required String groupId,
    required String description,
    required double amount,
    String? expenseDate,
    String? category,
    String? notes,
  }) async {
    final response = await dio.post(
      ApiConstants.expenses(groupId),
      data: {
        'description': description,
        'amount': amount,
        'date': expenseDate ?? DateTime.now().toIso8601String(),
      },
    );
    // Backend returns { expense, transaction }.
    final data = response.data is Map && response.data['expense'] != null
        ? response.data['expense']
        : response.data;
    return ExpenseModel.fromJson(data as Map<String, dynamic>);
  }
}
