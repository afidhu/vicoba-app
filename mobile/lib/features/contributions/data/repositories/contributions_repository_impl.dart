import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/contribution.dart';
import '../../domain/repositories/contributions_repository.dart';
import '../datasources/contributions_remote_datasource.dart';

class ContributionsRepositoryImpl implements ContributionsRepository {
  final ContributionsRemoteDataSource remoteDataSource;

  ContributionsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Contribution>>> getContributions(
    String groupId, {
    String? memberId,
  }) async {
    try {
      final result = await remoteDataSource.getContributions(groupId, memberId: memberId);
      return Right(result);
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, Contribution>> recordContribution({
    required String groupId,
    required String memberId,
    double? amount,
    required DateTime weekEnding,
  }) async {
    try {
      final data = {
        'memberId': memberId,
        if (amount != null) 'amount': amount,
        'weekEnding': DateFormatter.toIsoDateString(weekEnding),
      };
      final result = await remoteDataSource.recordContribution(groupId, data);
      return Right(result);
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }
}
