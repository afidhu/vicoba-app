import '../../domain/entities/contribution.dart';

class ContributionModel extends Contribution {
  const ContributionModel({
    required super.id,
    required super.groupId,
    required super.memberId,
    super.memberName,
    required super.amount,
    required super.weekEnding,
    required super.createdAt,
  });

  factory ContributionModel.fromJson(Map<String, dynamic> json) {
    final member = json['member'] as Map<String, dynamic>?;
    final amountVal = json['amount'];
    final double amount = (amountVal is num)
        ? amountVal.toDouble()
        : (double.tryParse(amountVal?.toString() ?? '0') ?? 0.0);

    return ContributionModel(
      id: json['id'] ?? '',
      groupId: json['groupId'] ?? '',
      memberId: json['memberId'] ?? '',
      memberName: member != null ? member['name'] : json['memberName'],
      amount: amount,
      weekEnding: json['weekEnding'] != null
          ? DateTime.parse(json['weekEnding'])
          : DateTime.now(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'memberId': memberId,
      'amount': amount,
      'weekEnding': weekEnding.toIso8601String(),
    };
  }
}
