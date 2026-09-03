import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/contribution.dart';
import '../repositories/contributions_repository.dart';

class GetContributionsUseCase {
  final ContributionsRepository repository;

  GetContributionsUseCase(this.repository);

  Future<Either<Failure, List<Contribution>>> call(
    String groupId, {
    String? memberId,
  }) {
    return repository.getContributions(groupId, memberId: memberId);
  }
}
