import 'package:equatable/equatable.dart';

class Member extends Equatable {
  final String id;
  final String groupId;
  final String? userId;
  final String role;
  final String name;
  final String? phone;
  final int shareHoldings;
  final DateTime joinedAt;
  final bool isActive;

  const Member({
    required this.id,
    required this.groupId,
    this.userId,
    this.role = 'MEMBER',
    required this.name,
    this.phone,
    this.shareHoldings = 0,
    required this.joinedAt,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        groupId,
        userId,
        role,
        name,
        phone,
        shareHoldings,
        joinedAt,
        isActive,
      ];
}
