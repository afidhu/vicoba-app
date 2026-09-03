import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/repayment_usecases.dart';
import 'repayments_event.dart';
import 'repayments_state.dart';

class RepaymentsBloc extends Bloc<RepaymentsEvent, RepaymentsState> {
  final GetRepaymentsUseCase getRepaymentsUseCase;
  final RecordRepaymentUseCase recordRepaymentUseCase;

  RepaymentsBloc({
    required this.getRepaymentsUseCase,
    required this.recordRepaymentUseCase,
  }) : super(RepaymentsInitial()) {
    on<LoadRepayments>(_onLoadRepayments);
    on<AddRepayment>(_onAddRepayment);
  }

  Future<void> _onLoadRepayments(LoadRepayments event, Emitter<RepaymentsState> emit) async {
    emit(RepaymentsLoading());
    final result = await getRepaymentsUseCase(event.groupId, event.loanId);
    result.fold(
      (failure) => emit(RepaymentsError(failure.message)),
      (repayments) => emit(RepaymentsLoaded(repayments)),
    );
  }

  Future<void> _onAddRepayment(AddRepayment event, Emitter<RepaymentsState> emit) async {
    emit(RepaymentsLoading());
    final result = await recordRepaymentUseCase(
      groupId: event.groupId,
      loanId: event.loanId,
      amount: event.amount,
    );
    result.fold(
      (failure) => emit(RepaymentsError(failure.message)),
      (_) {
        emit(RepaymentAdded());
        add(LoadRepayments(event.groupId, event.loanId));
      },
    );
  }
}
