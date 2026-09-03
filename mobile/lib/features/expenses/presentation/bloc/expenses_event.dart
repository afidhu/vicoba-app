import 'package:equatable/equatable.dart';

abstract class ExpensesEvent extends Equatable {
  const ExpensesEvent();

  @override
  List<Object?> get props => [];
}

class LoadExpenses extends ExpensesEvent {
  final String groupId;

  const LoadExpenses(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class AddExpense extends ExpensesEvent {
  final String groupId;
  final String description;
  final double amount;
  final DateTime? expenseDate;
  final String? category;
  final String? notes;

  const AddExpense({
    required this.groupId,
    required this.description,
    required this.amount,
    this.expenseDate,
    this.category,
    this.notes,
  });

  @override
  List<Object?> get props => [groupId, description, amount, expenseDate, category, notes];
}
