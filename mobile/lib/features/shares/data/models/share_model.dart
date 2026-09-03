import '../../domain/entities/share.dart';

class ShareModel extends Share {
  const ShareModel({
    required super.id,
    required super.groupId,
    required super.memberId,
    required super.quantity,
    required super.pricePerShare,
    required super.totalAmount,
    required super.purchaseDate,
    super.notes,
    required super.memberName,
  });

  factory ShareModel.fromJson(Map<String, dynamic> json) {
    return ShareModel(
      id: json['id'],
      groupId: json['groupId'],
      memberId: json['memberId'],
      quantity: json['quantity'],
      pricePerShare: (json['pricePerShare'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      purchaseDate: DateTime.parse(json['purchaseDate']),
      notes: json['notes'],
      memberName: json['member']?['name'] ?? 'Unknown',
    );
  }
}
