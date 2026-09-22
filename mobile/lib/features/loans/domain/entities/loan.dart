import 'package:equatable/equatable.dart';

class Loan extends Equatable {
  final String id;
  final String groupId;
  final String memberId;
  final double principalAmount;
  final double interestRate;
  final double interestAmount;
  final double totalRepayable;
  final double amountPaid;
  final double outstandingAmount;
  final DateTime? issueDate;
  final DateTime? dueDate;
  final String status;
  final String? notes;
  final String memberName;
  final List<LoanInstallment> repayments;

  const Loan({
    required this.id,
    required this.groupId,
    required this.memberId,
    required this.principalAmount,
    required this.interestRate,
    required this.interestAmount,
    required this.totalRepayable,
    required this.amountPaid,
    required this.outstandingAmount,
    this.issueDate,
    this.dueDate,
    required this.status,
    this.notes,
    required this.memberName,
    this.repayments = const [],
  });

  @override
  List<Object?> get props => [
        id,
        groupId,
        memberId,
        principalAmount,
        interestRate,
        interestAmount,
        totalRepayable,
        amountPaid,
        outstandingAmount,
        issueDate,
        dueDate,
        status,
        notes,
        memberName,
        repayments,
      ];
}

class LoanInstallment extends Equatable {
  final String id;
  final double amount;
  final DateTime paidAt;

  const LoanInstallment({required this.id, required this.amount, required this.paidAt});

  @override
  List<Object?> get props => [id, amount, paidAt];
}
