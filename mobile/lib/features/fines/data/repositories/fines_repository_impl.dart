import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../domain/entities/fine.dart';
import '../../domain/repositories/fines_repository.dart';
import '../datasources/fines_remote_datasource.dart';

class FinesRepositoryImpl implements FinesRepository {
  final FinesRemoteDataSource remoteDataSource;

  FinesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Fine>>> getFines(String groupId, {String? memberId, String? status}) async {
    try {
      return Right(await remoteDataSource.getFines(groupId, memberId: memberId, status: status));
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, Fine>> recordFine({
    required String groupId,
    required String memberId,
    required String reason,
    double? amount,
  }) async {
    try {
      return Right(await remoteDataSource.recordFine(
        groupId: groupId,
        memberId: memberId,
        reason: reason,
        amount: amount,
      ));
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, Fine>> updateFineStatus({
    required String groupId,
    required String fineId,
    required FineStatus status,
  }) async {
    try {
      return Right(await remoteDataSource.updateFineStatus(
        groupId: groupId,
        fineId: fineId,
        status: fineStatusToApi(status),
      ));
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }
}
