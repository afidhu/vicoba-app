import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/member.dart';
import '../repositories/members_repository.dart';

class AddMemberUseCase {
  final MembersRepository repository;

  AddMemberUseCase(this.repository);

  Future<Either<Failure, Member>> call({
    required String groupId,
    required String name,
    String? phone,
    String? role,
    String? userId,
  }) {
    return repository.addMember(
      groupId: groupId,
      name: name,
      phone: phone,
      role: role,
      userId: userId,
    );
  }
}
