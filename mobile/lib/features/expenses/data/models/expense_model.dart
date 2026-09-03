import '../../domain/entities/expense.dart';

class ExpenseModel extends Expense {
  const ExpenseModel({
    required super.id,
    required super.groupId,
    required super.description,
    required super.amount,
    required super.expenseDate,
    super.category,
    super.notes,
    required super.recordedBy,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    final amountVal = json['amount'];
    return ExpenseModel(
      id: json['id'] ?? '',
      groupId: json['groupId'] ?? '',
      description: json['description'] ?? '',
      amount: (amountVal is num)
          ? amountVal.toDouble()
          : (double.tryParse(amountVal?.toString() ?? '0') ?? 0.0),
      expenseDate: DateTime.tryParse(
              (json['date'] ?? json['expenseDate'] ?? '').toString()) ??
          DateTime.now(),
      category: json['category'],
      notes: json['notes'],
      recordedBy: json['recordedBy'] ?? '',
    );
  }
}
