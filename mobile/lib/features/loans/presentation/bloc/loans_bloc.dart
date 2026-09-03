import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/loan_usecases.dart';
import 'loans_event.dart';
import 'loans_state.dart';

class LoansBloc extends Bloc<LoansEvent, LoansState> {
  final GetLoansUseCase getLoansUseCase;
  final RequestLoanUseCase requestLoanUseCase;
  final ApproveLoanUseCase approveLoanUseCase;
  final RejectLoanUseCase rejectLoanUseCase;

  LoansBloc({
    required this.getLoansUseCase,
    required this.requestLoanUseCase,
    required this.approveLoanUseCase,
    required this.rejectLoanUseCase,
  }) : super(LoansInitial()) {
    on<LoadLoans>(_onLoadLoans);
    on<RequestLoan>(_onRequestLoan);
    on<ApproveLoan>(_onApproveLoan);
    on<RejectLoan>(_onRejectLoan);
  }

  Future<void> _onLoadLoans(LoadLoans event, Emitter<LoansState> emit) async {
    emit(LoansLoading());
    final result = await getLoansUseCase(event.groupId, memberId: event.memberId, status: event.status);
    result.fold(
      (failure) => emit(LoansError(failure.message)),
      (loans) => emit(LoansLoaded(loans)),
    );
  }

  Future<void> _onRequestLoan(RequestLoan event, Emitter<LoansState> emit) async {
    emit(LoansLoading());
    final result = await requestLoanUseCase(
      groupId: event.groupId,
      memberId: event.memberId,
      principalAmount: event.principalAmount,
      dueDate: event.dueDate,
      notes: event.notes,
    );
    result.fold(
      (failure) => emit(LoansError(failure.message)),
      (_) {
        emit(LoanActionSuccess());
        add(LoadLoans(event.groupId));
      },
    );
  }

  Future<void> _onApproveLoan(ApproveLoan event, Emitter<LoansState> emit) async {
    emit(LoansLoading());
    final result = await approveLoanUseCase(event.groupId, event.loanId);
    result.fold(
      (failure) => emit(LoansError(failure.message)),
      (_) {
        emit(LoanActionSuccess());
        add(LoadLoans(event.groupId));
      },
    );
  }

  Future<void> _onRejectLoan(RejectLoan event, Emitter<LoansState> emit) async {
    emit(LoansLoading());
    final result = await rejectLoanUseCase(event.groupId, event.loanId);
    result.fold(
      (failure) => emit(LoansError(failure.message)),
      (_) {
        emit(LoanActionSuccess());
        add(LoadLoans(event.groupId));
      },
    );
  }
}
