import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_group_summary_usecase.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetGroupSummaryUseCase getGroupSummaryUseCase;

  DashboardBloc({required this.getGroupSummaryUseCase}) : super(DashboardInitial()) {
    on<LoadDashboardSummaryEvent>(_onLoadDashboardSummary);
  }

  Future<void> _onLoadDashboardSummary(
    LoadDashboardSummaryEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    final result = await getGroupSummaryUseCase(event.groupId);
    result.fold(
      (failure) => emit(DashboardError(failure.message)),
      (summary) => emit(DashboardLoaded(summary)),
    );
  }
}
