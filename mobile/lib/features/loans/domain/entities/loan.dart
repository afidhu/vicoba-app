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
      ];
}
