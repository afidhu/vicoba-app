import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_shares_usecase.dart';
import '../../domain/usecases/buy_shares_usecase.dart';
import 'shares_event.dart';
import 'shares_state.dart';

class SharesBloc extends Bloc<SharesEvent, SharesState> {
  final GetSharesUseCase getSharesUseCase;
  final BuySharesUseCase buySharesUseCase;

  SharesBloc({
    required this.getSharesUseCase,
    required this.buySharesUseCase,
  }) : super(SharesInitial()) {
    on<LoadShares>(_onLoadShares);
    on<BuyShares>(_onBuyShares);
  }

  Future<void> _onLoadShares(LoadShares event, Emitter<SharesState> emit) async {
    emit(SharesLoading());
    final result = await getSharesUseCase(event.groupId);
    result.fold(
      (failure) => emit(SharesError(failure.message)),
      (summary) => emit(SharesLoaded(summary)),
    );
  }

  Future<void> _onBuyShares(BuyShares event, Emitter<SharesState> emit) async {
    emit(SharesLoading());
    final result = await buySharesUseCase(
      groupId: event.groupId,
      memberId: event.memberId,
      quantity: event.quantity,
    );
    result.fold(
      (failure) => emit(SharesError(failure.message)),
      (_) {
        emit(SharesBought());
        add(LoadShares(event.groupId));
      },
    );
  }
}
