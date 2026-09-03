import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/expense_usecases.dart';
import 'expenses_event.dart';
import 'expenses_state.dart';

class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  final GetExpensesUseCase getExpensesUseCase;
  final RecordExpenseUseCase recordExpenseUseCase;

  ExpensesBloc({
    required this.getExpensesUseCase,
    required this.recordExpenseUseCase,
  }) : super(ExpensesInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<AddExpense>(_onAddExpense);
  }

  Future<void> _onLoadExpenses(LoadExpenses event, Emitter<ExpensesState> emit) async {
    emit(ExpensesLoading());
    final result = await getExpensesUseCase(event.groupId);
    result.fold(
      (failure) => emit(ExpensesError(failure.message)),
      (expenses) => emit(ExpensesLoaded(expenses)),
    );
  }

  Future<void> _onAddExpense(AddExpense event, Emitter<ExpensesState> emit) async {
    emit(ExpensesLoading());
    final result = await recordExpenseUseCase(
      groupId: event.groupId,
      description: event.description,
      amount: event.amount,
      expenseDate: event.expenseDate,
      category: event.category,
      notes: event.notes,
    );
    result.fold(
      (failure) => emit(ExpensesError(failure.message)),
      (_) {
        emit(ExpenseAdded());
        add(LoadExpenses(event.groupId));
      },
    );
  }
}
