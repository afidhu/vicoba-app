import 'package:equatable/equatable.dart';

abstract class SharesEvent extends Equatable {
  const SharesEvent();

  @override
  List<Object?> get props => [];
}

class LoadShares extends SharesEvent {
  final String groupId;

  const LoadShares(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class BuyShares extends SharesEvent {
  final String groupId;
  final String memberId;
  final int quantity;

  const BuyShares({
    required this.groupId,
    required this.memberId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [groupId, memberId, quantity];
}
