import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/group.dart';
import '../repositories/groups_repository.dart';

class GetGroupsUseCase {
  final GroupsRepository repository;

  GetGroupsUseCase(this.repository);

  Future<Either<Failure, List<Group>>> call() {
    return repository.getGroups();
  }
}
