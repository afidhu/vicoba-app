import 'package:equatable/equatable.dart';

class Contribution extends Equatable {
  final String id;
  final String groupId;
  final String memberId;
  final String? memberName;
  final double amount;
  final DateTime weekEnding;
  final DateTime createdAt;

  const Contribution({
    required this.id,
    required this.groupId,
    required this.memberId,
    this.memberName,
    required this.amount,
    required this.weekEnding,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        groupId,
        memberId,
        memberName,
        amount,
        weekEnding,
        createdAt,
      ];
}
