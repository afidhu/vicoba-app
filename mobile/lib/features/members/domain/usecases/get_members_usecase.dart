import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/member.dart';
import '../repositories/members_repository.dart';

class GetMembersUseCase {
  final MembersRepository repository;

  GetMembersUseCase(this.repository);

  Future<Either<Failure, List<Member>>> call(String groupId) {
    return repository.getMembers(groupId);
  }
}
