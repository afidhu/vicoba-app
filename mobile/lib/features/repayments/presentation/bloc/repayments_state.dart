import 'package:equatable/equatable.dart';
import '../../domain/entities/repayment.dart';

abstract class RepaymentsState extends Equatable {
  const RepaymentsState();
  
  @override
  List<Object?> get props => [];
}

class RepaymentsInitial extends RepaymentsState {}

class RepaymentsLoading extends RepaymentsState {}

class RepaymentsLoaded extends RepaymentsState {
  final List<Repayment> repayments;

  const RepaymentsLoaded(this.repayments);

  @override
  List<Object?> get props => [repayments];
}

class RepaymentsError extends RepaymentsState {
  final String message;

  const RepaymentsError(this.message);

  @override
  List<Object?> get props => [message];
}

class RepaymentAdded extends RepaymentsState {}
