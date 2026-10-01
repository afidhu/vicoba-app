import '../../domain/entities/member.dart';

class MemberModel extends Member {
  const MemberModel({
    required super.id,
    required super.groupId,
    super.userId,
    super.role = 'MEMBER',
    required super.name,
    super.phone,
    super.nidaNumber,
    super.shareHoldings = 0,
    required super.joinedAt,
    super.isActive = true,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'] ?? '',
      groupId: json['groupId'] ?? '',
      userId: json['userId'],
      role: json['role'] ?? 'MEMBER',
      name: json['name'] ?? '',
      phone: json['phone'],
      nidaNumber: json['nidaNumber'],
      shareHoldings: (json['shareHoldings'] is num)
          ? (json['shareHoldings'] as num).toInt()
          : 0,
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'])
          : DateTime.now(),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      if (userId != null) 'userId': userId,
      'role': role,
      'name': name,
      if (phone != null) 'phone': phone,
      if (nidaNumber != null) 'nidaNumber': nidaNumber,
      'shareHoldings': shareHoldings,
      'joinedAt': joinedAt.toIso8601String(),
      'isActive': isActive,
    };
  }
}
