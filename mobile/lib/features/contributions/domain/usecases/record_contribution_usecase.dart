import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/contribution.dart';
import '../repositories/contributions_repository.dart';

class RecordContributionUseCase {
  final ContributionsRepository repository;

  RecordContributionUseCase(this.repository);

  Future<Either<Failure, Contribution>> call({
    required String groupId,
    required String memberId,
    double? amount,
    required DateTime weekEnding,
  }) {
    return repository.recordContribution(
      groupId: groupId,
      memberId: memberId,
      amount: amount,
      weekEnding: weekEnding,
    );
  }
}
