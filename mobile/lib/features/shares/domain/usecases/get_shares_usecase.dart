import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/shares_summary.dart';
import '../repositories/shares_repository.dart';

class GetSharesUseCase {
  final SharesRepository repository;

  GetSharesUseCase(this.repository);

  Future<Either<Failure, SharesSummary>> call(String groupId) {
    return repository.getSharesSummary(groupId);
  }
}
