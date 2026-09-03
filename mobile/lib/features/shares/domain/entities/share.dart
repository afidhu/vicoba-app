import 'package:equatable/equatable.dart';

class Share extends Equatable {
  final String id;
  final String groupId;
  final String memberId;
  final int quantity;
  final double pricePerShare;
  final double totalAmount;
  final DateTime purchaseDate;
  final String? notes;
  final String memberName;

  const Share({
    required this.id,
    required this.groupId,
    required this.memberId,
    required this.quantity,
    required this.pricePerShare,
    required this.totalAmount,
    required this.purchaseDate,
    this.notes,
    required this.memberName,
  });

  @override
  List<Object?> get props => [id, groupId, memberId, quantity, pricePerShare, totalAmount, purchaseDate, notes, memberName];
}
