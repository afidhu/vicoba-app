import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/fine.dart';
import '../repositories/fines_repository.dart';

class GetFinesUseCase {
  final FinesRepository repository;
  GetFinesUseCase(this.repository);
  Future<Either<Failure, List<Fine>>> call(String groupId, {String? memberId, String? status}) {
    return repository.getFines(groupId, memberId: memberId, status: status);
  }
}

class RecordFineUseCase {
  final FinesRepository repository;
  RecordFineUseCase(this.repository);
  Future<Either<Failure, Fine>> call({
    required String groupId,
    required String memberId,
    required String reason,
    double? amount,
  }) {
    return repository.recordFine(
      groupId: groupId,
      memberId: memberId,
      reason: reason,
      amount: amount,
    );
  }
}

class UpdateFineStatusUseCase {
  final FinesRepository repository;
  UpdateFineStatusUseCase(this.repository);
  Future<Either<Failure, Fine>> call({
    required String groupId,
    required String fineId,
    required FineStatus status,
  }) {
    return repository.updateFineStatus(groupId: groupId, fineId: fineId, status: status);
  }
}
