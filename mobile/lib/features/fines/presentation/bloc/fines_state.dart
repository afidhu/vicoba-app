import 'package:equatable/equatable.dart';
import '../../domain/entities/fine.dart';

abstract class FinesState extends Equatable {
  const FinesState();

  @override
  List<Object?> get props => [];
}

class FinesInitial extends FinesState {}

class FinesLoading extends FinesState {}

class FinesLoaded extends FinesState {
  final List<Fine> fines;

  const FinesLoaded(this.fines);

  double get unpaidTotal => fines
      .where((f) => f.status == FineStatus.unpaid)
      .fold(0.0, (sum, f) => sum + f.amount);

  @override
  List<Object?> get props => [fines];
}

class FinesError extends FinesState {
  final String message;

  const FinesError(this.message);

  @override
  List<Object?> get props => [message];
}

class FineActionSuccess extends FinesState {
  final String message;
  const FineActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
