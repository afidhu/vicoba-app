import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/group.dart';
import '../repositories/groups_repository.dart';

class GetGroupDetailsUseCase {
  final GroupsRepository repository;

  GetGroupDetailsUseCase(this.repository);

  Future<Either<Failure, Group>> call(String groupId) {
    return repository.getGroupDetails(groupId);
  }
}
