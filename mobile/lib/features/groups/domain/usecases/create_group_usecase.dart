import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/group.dart';
import '../repositories/groups_repository.dart';

class CreateGroupUseCase {
  final GroupsRepository repository;

  CreateGroupUseCase(this.repository);

  Future<Either<Failure, Group>> call({
    required String name,
    String? location,
    String? meetingDay,
    double? weeklyContribution,
    double? sharePrice,
    double? fineDefaultAmount,
    double? loanInterestRate,
  }) {
    return repository.createGroup(
      name: name,
      location: location,
      meetingDay: meetingDay,
      weeklyContribution: weeklyContribution,
      sharePrice: sharePrice,
      fineDefaultAmount: fineDefaultAmount,
      loanInterestRate: loanInterestRate,
    );
  }
}
