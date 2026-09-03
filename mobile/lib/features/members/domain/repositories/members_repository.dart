import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/member.dart';

abstract class MembersRepository {
  Future<Either<Failure, List<Member>>> getMembers(String groupId);
  Future<Either<Failure, Member>> getMemberDetails(String groupId, String memberId);
  Future<Either<Failure, Member>> addMember({
    required String groupId,
    required String name,
    String? phone,
    String? role,
    String? userId,
  });
  Future<Either<Failure, Member>> updateMember({
    required String groupId,
    required String memberId,
    String? name,
    String? phone,
    String? role,
    bool? isActive,
  });
}
