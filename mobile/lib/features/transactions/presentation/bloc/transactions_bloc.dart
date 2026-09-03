import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import 'transactions_event.dart';
import 'transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final GetTransactionsUseCase getTransactionsUseCase;

  TransactionsBloc({required this.getTransactionsUseCase}) : super(TransactionsInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
  }

  Future<void> _onLoadTransactions(LoadTransactions event, Emitter<TransactionsState> emit) async {
    emit(TransactionsLoading());
    final result = await getTransactionsUseCase(event.groupId, memberId: event.memberId, type: event.type);
    result.fold(
      (failure) => emit(TransactionsError(failure.message)),
      (transactions) => emit(TransactionsLoaded(transactions)),
    );
  }
}
