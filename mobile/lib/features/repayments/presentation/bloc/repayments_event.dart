import 'package:equatable/equatable.dart';

abstract class RepaymentsEvent extends Equatable {
  const RepaymentsEvent();

  @override
  List<Object?> get props => [];
}

class LoadRepayments extends RepaymentsEvent {
  final String groupId;
  final String loanId;

  const LoadRepayments(this.groupId, this.loanId);

  @override
  List<Object?> get props => [groupId, loanId];
}

class AddRepayment extends RepaymentsEvent {
  final String groupId;
  final String loanId;
  final double amount;

  const AddRepayment({
    required this.groupId,
    required this.loanId,
    required this.amount,
  });

  @override
  List<Object?> get props => [groupId, loanId, amount];
}
