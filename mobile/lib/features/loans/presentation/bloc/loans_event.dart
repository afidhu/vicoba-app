import 'package:equatable/equatable.dart';

abstract class LoansEvent extends Equatable {
  const LoansEvent();

  @override
  List<Object?> get props => [];
}

class LoadLoans extends LoansEvent {
  final String groupId;
  final String? memberId;
  final String? status;

  const LoadLoans(this.groupId, {this.memberId, this.status});

  @override
  List<Object?> get props => [groupId, memberId, status];
}

class RequestLoan extends LoansEvent {
  final String groupId;
  final String memberId;
  final double principalAmount;
  final DateTime dueDate;
  final String? notes;

  const RequestLoan({
    required this.groupId,
    required this.memberId,
    required this.principalAmount,
    required this.dueDate,
    this.notes,
  });

  @override
  List<Object?> get props => [groupId, memberId, principalAmount, dueDate, notes];
}

class ApproveLoan extends LoansEvent {
  final String loanId;
  final String groupId;

  const ApproveLoan(this.loanId, this.groupId);

  @override
  List<Object?> get props => [loanId, groupId];
}

class RejectLoan extends LoansEvent {
  final String loanId;
  final String groupId;

  const RejectLoan(this.loanId, this.groupId);

  @override
  List<Object?> get props => [loanId, groupId];
}
