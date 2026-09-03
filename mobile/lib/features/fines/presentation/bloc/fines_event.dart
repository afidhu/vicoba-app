import 'package:equatable/equatable.dart';
import '../../domain/entities/fine.dart';

abstract class FinesEvent extends Equatable {
  const FinesEvent();

  @override
  List<Object?> get props => [];
}

class LoadFines extends FinesEvent {
  final String groupId;
  final String? memberId;

  const LoadFines(this.groupId, {this.memberId});

  @override
  List<Object?> get props => [groupId, memberId];
}

class RecordFine extends FinesEvent {
  final String groupId;
  final String memberId;
  final String reason;
  final double? amount;

  const RecordFine({
    required this.groupId,
    required this.memberId,
    required this.reason,
    this.amount,
  });

  @override
  List<Object?> get props => [groupId, memberId, reason, amount];
}

class UpdateFineStatus extends FinesEvent {
  final String groupId;
  final String fineId;
  final FineStatus status;

  const UpdateFineStatus({
    required this.groupId,
    required this.fineId,
    required this.status,
  });

  @override
  List<Object?> get props => [groupId, fineId, status];
}
