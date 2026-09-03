import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expenses_repository.dart';
import '../datasources/expenses_remote_datasource.dart';

class ExpensesRepositoryImpl implements ExpensesRepository {
  final ExpensesRemoteDataSource remoteDataSource;

  ExpensesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Expense>>> getExpenses(String groupId) async {
    try {
      final expenses = await remoteDataSource.getExpenses(groupId);
      return Right(expenses);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Failed to load expenses'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Expense>> recordExpense({
    required String groupId,
    required String description,
    required double amount,
    DateTime? expenseDate,
    String? category,
    String? notes,
  }) async {
    try {
      final expense = await remoteDataSource.recordExpense(
        groupId: groupId,
        description: description,
        amount: amount,
        expenseDate: expenseDate?.toIso8601String(),
        category: category,
        notes: notes,
      );
      return Right(expense);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Failed to record expense'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
