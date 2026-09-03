import 'package:equatable/equatable.dart';

abstract class TransactionsEvent extends Equatable {
  const TransactionsEvent();
  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionsEvent {
  final String groupId;
  final String? memberId;
  final String? type;

  const LoadTransactions(this.groupId, {this.memberId, this.type});

  @override
  List<Object?> get props => [groupId, memberId, type];
}
