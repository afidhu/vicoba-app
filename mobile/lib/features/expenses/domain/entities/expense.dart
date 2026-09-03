import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  final String id;
  final String groupId;
  final String description;
  final double amount;
  final DateTime expenseDate;
  final String? category;
  final String? notes;
  final String recordedBy;

  const Expense({
    required this.id,
    required this.groupId,
    required this.description,
    required this.amount,
    required this.expenseDate,
    this.category,
    this.notes,
    required this.recordedBy,
  });

  @override
  List<Object?> get props => [id, groupId, description, amount, expenseDate, category, notes, recordedBy];
}
