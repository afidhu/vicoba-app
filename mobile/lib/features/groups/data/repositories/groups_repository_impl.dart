import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../domain/entities/group.dart';
import '../../domain/repositories/groups_repository.dart';
import '../datasources/groups_remote_datasource.dart';

class GroupsRepositoryImpl implements GroupsRepository {
  final GroupsRemoteDataSource remoteDataSource;

  GroupsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Group>>> getGroups() async {
    try {
      final result = await remoteDataSource.getGroups();
      return Right(result);
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, Group>> getGroupDetails(String groupId) async {
    try {
      final result = await remoteDataSource.getGroupDetails(groupId);
      return Right(result);
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, Group>> createGroup({
    required String name,
    String? location,
    String? meetingDay,
    double? weeklyContribution,
    double? sharePrice,
    double? fineDefaultAmount,
    double? loanInterestRate,
  }) async {
    try {
      final data = {
        'name': name,
        if (location != null && location.isNotEmpty) 'location': location,
        if (meetingDay != null && meetingDay.isNotEmpty) 'meetingDay': meetingDay,
        if (weeklyContribution != null) 'weeklyContribution': weeklyContribution,
        if (sharePrice != null) 'sharePrice': sharePrice,
        if (fineDefaultAmount != null) 'fineDefaultAmount': fineDefaultAmount,
        if (loanInterestRate != null) 'loanInterestRate': loanInterestRate,
      };
      final result = await remoteDataSource.createGroup(data);
      return Right(result);
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, Group>> updateGroup(
    String groupId, {
    String? name,
    String? location,
    String? meetingDay,
    double? weeklyContribution,
    double? sharePrice,
    double? fineDefaultAmount,
    double? loanInterestRate,
  }) async {
    try {
      final data = {
        if (name != null) 'name': name,
        if (location != null) 'location': location,
        if (meetingDay != null) 'meetingDay': meetingDay,
        if (weeklyContribution != null) 'weeklyContribution': weeklyContribution,
        if (sharePrice != null) 'sharePrice': sharePrice,
        if (fineDefaultAmount != null) 'fineDefaultAmount': fineDefaultAmount,
        if (loanInterestRate != null) 'loanInterestRate': loanInterestRate,
      };
      final result = await remoteDataSource.updateGroup(groupId, data);
      return Right(result);
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }
}
