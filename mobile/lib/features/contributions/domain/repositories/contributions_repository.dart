import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/contribution.dart';

abstract class ContributionsRepository {
  Future<Either<Failure, List<Contribution>>> getContributions(
    String groupId, {
    String? memberId,
  });
  Future<Either<Failure, Contribution>> recordContribution({
    required String groupId,
    required String memberId,
    double? amount,
    required DateTime weekEnding,
  });
}
