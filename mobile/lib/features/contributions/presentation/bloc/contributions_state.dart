import 'package:equatable/equatable.dart';
import '../../domain/entities/contribution.dart';

abstract class ContributionsState extends Equatable {
  const ContributionsState();

  @override
  List<Object?> get props => [];
}

class ContributionsInitial extends ContributionsState {}

class ContributionsLoading extends ContributionsState {}

class ContributionsLoaded extends ContributionsState {
  final List<Contribution> contributions;

  const ContributionsLoaded(this.contributions);

  @override
  List<Object?> get props => [contributions];
}

class ContributionOperationSuccess extends ContributionsState {
  final String message;
  final Contribution? contribution;

  const ContributionOperationSuccess(this.message, {this.contribution});

  @override
  List<Object?> get props => [message, contribution];
}

class ContributionsError extends ContributionsState {
  final String message;

  const ContributionsError(this.message);

  @override
  List<Object?> get props => [message];
}
