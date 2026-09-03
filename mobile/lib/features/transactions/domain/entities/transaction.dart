import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final String id;
  final String groupId;
  final String? memberId;
  final String type;
  final double amount;
  final String? description;
  final String? referenceId;
  final DateTime transactionDate;
  final String createdBy;
  final String? memberName;

  const Transaction({
    required this.id,
    required this.groupId,
    this.memberId,
    required this.type,
    required this.amount,
    this.description,
    this.referenceId,
    required this.transactionDate,
    required this.createdBy,
    this.memberName,
  });

  @override
  List<Object?> get props => [id, groupId, memberId, type, amount, description, referenceId, transactionDate, createdBy, memberName];
}
