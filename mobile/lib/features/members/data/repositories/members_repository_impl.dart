import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../domain/entities/member.dart';
import '../../domain/repositories/members_repository.dart';
import '../datasources/members_remote_datasource.dart';

class MembersRepositoryImpl implements MembersRepository {
  final MembersRemoteDataSource remoteDataSource;

  MembersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Member>>> getMembers(String groupId) async {
    try {
      final result = await remoteDataSource.getMembers(groupId);
      return Right(result);
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, Member>> getMemberDetails(String groupId, String memberId) async {
    try {
      final result = await remoteDataSource.getMemberDetails(groupId, memberId);
      return Right(result);
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, Member>> addMember({
    required String groupId,
    required String name,
    String? phone,
    String? role,
    String? userId,
  }) async {
    try {
      final data = {
        'name': name,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (role != null) 'role': role,
        if (userId != null && userId.isNotEmpty) 'userId': userId,
      };
      final result = await remoteDataSource.addMember(groupId, data);
      return Right(result);
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, Member>> updateMember({
    required String groupId,
    required String memberId,
    String? name,
    String? phone,
    String? role,
    bool? isActive,
  }) async {
    try {
      final data = {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (role != null) 'role': role,
        if (isActive != null) 'isActive': isActive,
      };
      final result = await remoteDataSource.updateMember(groupId, memberId, data);
      return Right(result);
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }
}
