import 'package:equatable/equatable.dart';
import '../../domain/entities/loan.dart';

abstract class LoansState extends Equatable {
  const LoansState();
  
  @override
  List<Object?> get props => [];
}

class LoansInitial extends LoansState {}

class LoansLoading extends LoansState {}

class LoansLoaded extends LoansState {
  final List<Loan> loans;

  const LoansLoaded(this.loans);

  @override
  List<Object?> get props => [loans];
}

class LoansError extends LoansState {
  final String message;

  const LoansError(this.message);

  @override
  List<Object?> get props => [message];
}

class LoanActionSuccess extends LoansState {}
