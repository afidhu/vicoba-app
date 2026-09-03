import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/reports.dart';
import '../repositories/reports_repository.dart';

class GetFinancialSummaryUseCase {
  final ReportsRepository repository;
  GetFinancialSummaryUseCase(this.repository);
  Future<Either<Failure, GroupFinancialSummary>> call(String groupId, {DateTime? startDate, DateTime? endDate}) =>
      repository.getFinancialSummary(groupId, startDate: startDate, endDate: endDate);
}

class GetMemberReportUseCase {
  final ReportsRepository repository;
  GetMemberReportUseCase(this.repository);
  Future<Either<Failure, MemberFinancialReport>> call(String groupId, String memberId) =>
      repository.getMemberReport(groupId, memberId);
}
