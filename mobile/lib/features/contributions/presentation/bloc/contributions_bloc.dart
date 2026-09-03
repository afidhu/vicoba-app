import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_contributions_usecase.dart';
import '../../domain/usecases/record_contribution_usecase.dart';
import 'contributions_event.dart';
import 'contributions_state.dart';

class ContributionsBloc extends Bloc<ContributionsEvent, ContributionsState> {
  final GetContributionsUseCase getContributionsUseCase;
  final RecordContributionUseCase recordContributionUseCase;

  ContributionsBloc({
    required this.getContributionsUseCase,
    required this.recordContributionUseCase,
  }) : super(ContributionsInitial()) {
    on<LoadContributionsEvent>(_onLoadContributions);
    on<RecordContributionEvent>(_onRecordContribution);
  }

  Future<void> _onLoadContributions(
    LoadContributionsEvent event,
    Emitter<ContributionsState> emit,
  ) async {
    emit(ContributionsLoading());
    final result = await getContributionsUseCase(
      event.groupId,
      memberId: event.memberId,
    );
    result.fold(
      (failure) => emit(ContributionsError(failure.message)),
      (contributions) => emit(ContributionsLoaded(contributions)),
    );
  }

  Future<void> _onRecordContribution(
    RecordContributionEvent event,
    Emitter<ContributionsState> emit,
  ) async {
    emit(ContributionsLoading());
    final result = await recordContributionUseCase(
      groupId: event.groupId,
      memberId: event.memberId,
      amount: event.amount,
      weekEnding: event.weekEnding,
    );
    result.fold(
      (failure) => emit(ContributionsError(failure.message)),
      (contribution) {
        emit(ContributionOperationSuccess(
          'Contribution recorded successfully',
          contribution: contribution,
        ));
        add(LoadContributionsEvent(groupId: event.groupId));
      },
    );
  }
}
