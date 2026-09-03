import 'package:equatable/equatable.dart';

enum FineStatus { unpaid, paid, waived }

FineStatus fineStatusFromString(String? s) {
  switch ((s ?? '').toUpperCase()) {
    case 'PAID':
      return FineStatus.paid;
    case 'WAIVED':
      return FineStatus.waived;
    default:
      return FineStatus.unpaid;
  }
}

String fineStatusToApi(FineStatus status) {
  switch (status) {
    case FineStatus.paid:
      return 'PAID';
    case FineStatus.waived:
      return 'WAIVED';
    case FineStatus.unpaid:
      return 'UNPAID';
  }
}

class Fine extends Equatable {
  final String id;
  final String groupId;
  final String memberId;
  final String? memberName;
  final String reason;
  final double amount;
  final FineStatus status;
  final DateTime issuedAt;

  const Fine({
    required this.id,
    required this.groupId,
    required this.memberId,
    this.memberName,
    required this.reason,
    required this.amount,
    required this.status,
    required this.issuedAt,
  });

  @override
  List<Object?> get props =>
      [id, groupId, memberId, memberName, reason, amount, status, issuedAt];
}
