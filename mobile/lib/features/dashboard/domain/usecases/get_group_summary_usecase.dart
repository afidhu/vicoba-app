import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/dashboard_summary.dart';
import '../repositories/dashboard_repository.dart';

class GetGroupSummaryUseCase {
  final DashboardRepository repository;

  GetGroupSummaryUseCase(this.repository);

  Future<Either<Failure, DashboardSummary>> call(String groupId) {
    return repository.getGroupSummary(groupId);
  }
}
