import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../domain/entities/shares_summary.dart';
import '../../domain/repositories/shares_repository.dart';
import '../datasources/shares_remote_datasource.dart';

class SharesRepositoryImpl implements SharesRepository {
  final SharesRemoteDataSource remoteDataSource;

  SharesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, SharesSummary>> getSharesSummary(String groupId) async {
    try {
      return Right(await remoteDataSource.getSharesSummary(groupId));
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> purchaseShares({
    required String groupId,
    required String memberId,
    required int quantity,
  }) async {
    try {
      return Right(
        await remoteDataSource.purchaseShares(groupId, memberId, quantity),
      );
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }
}
