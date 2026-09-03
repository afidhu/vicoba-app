import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/reports.dart';

abstract class ReportsRepository {
  Future<Either<Failure, GroupFinancialSummary>> getFinancialSummary(String groupId, {DateTime? startDate, DateTime? endDate});
  Future<Either<Failure, MemberFinancialReport>> getMemberReport(String groupId, String memberId);
}
