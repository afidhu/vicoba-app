import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/expense.dart';

abstract class ExpensesRepository {
  Future<Either<Failure, List<Expense>>> getExpenses(String groupId);
  Future<Either<Failure, Expense>> recordExpense({
    required String groupId,
    required String description,
    required double amount,
    DateTime? expenseDate,
    String? category,
    String? notes,
  });
}
