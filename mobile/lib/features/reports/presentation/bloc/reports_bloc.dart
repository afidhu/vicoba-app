import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/report_usecases.dart';
import 'reports_event.dart';
import 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final GetFinancialSummaryUseCase getFinancialSummaryUseCase;
  final GetMemberReportUseCase getMemberReportUseCase;

  ReportsBloc({
    required this.getFinancialSummaryUseCase,
    required this.getMemberReportUseCase,
  }) : super(ReportsInitial()) {
    on<LoadGroupFinancialSummary>(_onLoadGroupFinancialSummary);
    on<LoadMemberReport>(_onLoadMemberReport);
  }

  Future<void> _onLoadGroupFinancialSummary(LoadGroupFinancialSummary event, Emitter<ReportsState> emit) async {
    emit(ReportsLoading());
    final result = await getFinancialSummaryUseCase(event.groupId, startDate: event.startDate, endDate: event.endDate);
    result.fold(
      (failure) => emit(ReportsError(failure.message)),
      (summary) => emit(GroupFinancialSummaryLoaded(summary)),
    );
  }

  Future<void> _onLoadMemberReport(LoadMemberReport event, Emitter<ReportsState> emit) async {
    emit(ReportsLoading());
    final result = await getMemberReportUseCase(event.groupId, event.memberId);
    result.fold(
      (failure) => emit(ReportsError(failure.message)),
      (report) => emit(MemberReportLoaded(report)),
    );
  }
}
