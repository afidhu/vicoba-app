import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/reports.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_remote_datasource.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource remoteDataSource;
  ReportsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, GroupFinancialSummary>> getFinancialSummary(String groupId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      final summary = await remoteDataSource.getFinancialSummary(
        groupId,
        startDate: startDate?.toIso8601String(),
        endDate: endDate?.toIso8601String(),
      );
      return Right(summary);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Failed to load financial summary'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MemberFinancialReport>> getMemberReport(String groupId, String memberId) async {
    try {
      final report = await remoteDataSource.getMemberReport(groupId, memberId);
      return Right(report);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Failed to load member report'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
