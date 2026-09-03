import 'package:equatable/equatable.dart';
import '../../domain/entities/shares_summary.dart';

abstract class SharesState extends Equatable {
  const SharesState();

  @override
  List<Object?> get props => [];
}

class SharesInitial extends SharesState {}

class SharesLoading extends SharesState {}

class SharesLoaded extends SharesState {
  final SharesSummary summary;

  const SharesLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

class SharesError extends SharesState {
  final String message;

  const SharesError(this.message);

  @override
  List<Object?> get props => [message];
}

class SharesBought extends SharesState {}
