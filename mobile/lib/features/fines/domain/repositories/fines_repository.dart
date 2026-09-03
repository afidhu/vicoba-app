import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/fine.dart';

abstract class FinesRepository {
  Future<Either<Failure, List<Fine>>> getFines(String groupId, {String? memberId, String? status});
  Future<Either<Failure, Fine>> recordFine({
    required String groupId,
    required String memberId,
    required String reason,
    double? amount,
  });
  Future<Either<Failure, Fine>> updateFineStatus({
    required String groupId,
    required String fineId,
    required FineStatus status,
  });
}
