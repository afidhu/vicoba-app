import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/member.dart';
import '../repositories/members_repository.dart';

class GetMemberUseCase {
  final MembersRepository repository;

  GetMemberUseCase(this.repository);

  Future<Either<Failure, Member>> call(String groupId, String memberId) {
    return repository.getMemberDetails(groupId, memberId);
  }
}

class UpdateMemberUseCase {
  final MembersRepository repository;

  UpdateMemberUseCase(this.repository);

  Future<Either<Failure, Member>> call({
    required String groupId,
    required String memberId,
    String? name,
    String? phone,
    String? role,
    bool? isActive,
  }) {
    return repository.updateMember(
      groupId: groupId,
      memberId: memberId,
      name: name,
      phone: phone,
      role: role,
      isActive: isActive,
    );
  }
}
