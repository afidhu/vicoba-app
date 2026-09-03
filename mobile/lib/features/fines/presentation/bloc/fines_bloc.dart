import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/fine_usecases.dart';
import 'fines_event.dart';
import 'fines_state.dart';

class FinesBloc extends Bloc<FinesEvent, FinesState> {
  final GetFinesUseCase getFinesUseCase;
  final RecordFineUseCase recordFineUseCase;
  final UpdateFineStatusUseCase updateFineStatusUseCase;

  FinesBloc({
    required this.getFinesUseCase,
    required this.recordFineUseCase,
    required this.updateFineStatusUseCase,
  }) : super(FinesInitial()) {
    on<LoadFines>(_onLoad);
    on<RecordFine>(_onRecord);
    on<UpdateFineStatus>(_onUpdateStatus);
  }

  Future<void> _onLoad(LoadFines event, Emitter<FinesState> emit) async {
    emit(FinesLoading());
    final result = await getFinesUseCase(event.groupId, memberId: event.memberId);
    result.fold(
      (failure) => emit(FinesError(failure.message)),
      (fines) => emit(FinesLoaded(fines)),
    );
  }

  Future<void> _onRecord(RecordFine event, Emitter<FinesState> emit) async {
    emit(FinesLoading());
    final result = await recordFineUseCase(
      groupId: event.groupId,
      memberId: event.memberId,
      reason: event.reason,
      amount: event.amount,
    );
    await result.fold(
      (failure) async => emit(FinesError(failure.message)),
      (_) async {
        emit(const FineActionSuccess('Fine recorded'));
        add(LoadFines(event.groupId));
      },
    );
  }

  Future<void> _onUpdateStatus(UpdateFineStatus event, Emitter<FinesState> emit) async {
    final result = await updateFineStatusUseCase(
      groupId: event.groupId,
      fineId: event.fineId,
      status: event.status,
    );
    await result.fold(
      (failure) async => emit(FinesError(failure.message)),
      (_) async {
        emit(const FineActionSuccess('Fine updated'));
        add(LoadFines(event.groupId));
      },
    );
  }
}
