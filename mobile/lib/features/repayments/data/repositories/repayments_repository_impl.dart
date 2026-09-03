import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../domain/entities/repayment.dart';
import '../../domain/repositories/repayments_repository.dart';
import '../datasources/repayments_remote_datasource.dart';

class RepaymentsRepositoryImpl implements RepaymentsRepository {
  final RepaymentsRemoteDataSource remoteDataSource;

  RepaymentsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Repayment>>> getRepayments(String groupId, String loanId) async {
    try {
      return Right(await remoteDataSource.getRepayments(groupId, loanId));
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, Repayment>> recordRepayment({
    required String groupId,
    required String loanId,
    required double amount,
  }) async {
    try {
      return Right(await remoteDataSource.recordRepayment(
        groupId: groupId,
        loanId: loanId,
        amount: amount,
      ));
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }
}
