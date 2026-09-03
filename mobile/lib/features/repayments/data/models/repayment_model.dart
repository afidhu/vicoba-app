import '../../domain/entities/repayment.dart';

class RepaymentModel extends Repayment {
  const RepaymentModel({
    required super.id,
    required super.loanId,
    required super.amount,
    required super.repaymentDate,
    super.paymentMethod,
    super.notes,
    required super.recordedBy,
  });

  factory RepaymentModel.fromJson(Map<String, dynamic> json) {
    final amountVal = json['amount'];
    return RepaymentModel(
      id: json['id'] ?? '',
      loanId: json['loanId'] ?? '',
      amount: (amountVal is num)
          ? amountVal.toDouble()
          : (double.tryParse(amountVal?.toString() ?? '0') ?? 0.0),
      repaymentDate: DateTime.tryParse(
              (json['paidAt'] ?? json['createdAt'] ?? json['repaymentDate'] ?? '')
                  .toString()) ??
          DateTime.now(),
      paymentMethod: json['paymentMethod'],
      notes: json['notes'],
      recordedBy: json['recordedBy'] ?? '',
    );
  }
}
