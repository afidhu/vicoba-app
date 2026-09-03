import '../../domain/entities/fine.dart';

class FineModel extends Fine {
  const FineModel({
    required super.id,
    required super.groupId,
    required super.memberId,
    super.memberName,
    required super.reason,
    required super.amount,
    required super.status,
    required super.issuedAt,
  });

  factory FineModel.fromJson(Map<String, dynamic> json) {
    final amountVal = json['amount'];
    return FineModel(
      id: json['id'] ?? '',
      groupId: json['groupId'] ?? '',
      memberId: json['memberId'] ?? '',
      memberName: json['member']?['name'] ?? json['memberName'],
      reason: json['reason'] ?? '',
      amount: (amountVal is num)
          ? amountVal.toDouble()
          : (double.tryParse(amountVal?.toString() ?? '0') ?? 0.0),
      status: fineStatusFromString(json['status']),
      issuedAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}
