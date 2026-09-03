import 'package:equatable/equatable.dart';

class Repayment extends Equatable {
  final String id;
  final String loanId;
  final double amount;
  final DateTime repaymentDate;
  final String? paymentMethod;
  final String? notes;
  final String recordedBy;

  const Repayment({
    required this.id,
    required this.loanId,
    required this.amount,
    required this.repaymentDate,
    this.paymentMethod,
    this.notes,
    required this.recordedBy,
  });

  @override
  List<Object?> get props => [id, loanId, amount, repaymentDate, paymentMethod, notes, recordedBy];
}
