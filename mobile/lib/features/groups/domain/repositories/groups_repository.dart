import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/group.dart';

abstract class GroupsRepository {
  Future<Either<Failure, List<Group>>> getGroups();
  Future<Either<Failure, Group>> getGroupDetails(String groupId);
  Future<Either<Failure, Group>> createGroup({
    required String name,
    String? location,
    String? meetingDay,
    double? weeklyContribution,
    double? sharePrice,
    double? fineDefaultAmount,
    double? loanInterestRate,
  });
  Future<Either<Failure, Group>> updateGroup(
    String groupId, {
    String? name,
    String? location,
    String? meetingDay,
    double? weeklyContribution,
    double? sharePrice,
    double? fineDefaultAmount,
    double? loanInterestRate,
  });
}
