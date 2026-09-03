import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.groupId,
    super.memberId,
    required super.type,
    required super.amount,
    super.description,
    super.referenceId,
    required super.transactionDate,
    required super.createdBy,
    super.memberName,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final amountVal = json['amount'];
    return TransactionModel(
      id: json['id'] ?? '',
      groupId: json['groupId'] ?? '',
      memberId: json['memberId'],
      type: json['type'] ?? '',
      amount: (amountVal is num)
          ? amountVal.toDouble()
          : (double.tryParse(amountVal?.toString() ?? '0') ?? 0.0),
      description: json['description'],
      referenceId: json['refId'] ?? json['referenceId'],
      transactionDate: DateTime.tryParse(
              (json['createdAt'] ?? json['transactionDate'] ?? '').toString()) ??
          DateTime.now(),
      createdBy: json['createdBy'] ?? '',
      memberName: json['member']?['name'],
    );
  }
}
