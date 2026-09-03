import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/expense.dart';
import '../repositories/expenses_repository.dart';

class GetExpensesUseCase {
  final ExpensesRepository repository;
  GetExpensesUseCase(this.repository);
  Future<Either<Failure, List<Expense>>> call(String groupId) {
    return repository.getExpenses(groupId);
  }
}

class RecordExpenseUseCase {
  final ExpensesRepository repository;
  RecordExpenseUseCase(this.repository);
  Future<Either<Failure, Expense>> call({
    required String groupId,
    required String description,
    required double amount,
    DateTime? expenseDate,
    String? category,
    String? notes,
  }) {
    return repository.recordExpense(
      groupId: groupId,
      description: description,
      amount: amount,
      expenseDate: expenseDate,
      category: category,
      notes: notes,
    );
  }
}
