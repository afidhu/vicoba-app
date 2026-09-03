import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/repayment.dart';
import '../repositories/repayments_repository.dart';

class GetRepaymentsUseCase {
  final RepaymentsRepository repository;
  GetRepaymentsUseCase(this.repository);
  Future<Either<Failure, List<Repayment>>> call(String groupId, String loanId) {
    return repository.getRepayments(groupId, loanId);
  }
}

class RecordRepaymentUseCase {
  final RepaymentsRepository repository;
  RecordRepaymentUseCase(this.repository);
  Future<Either<Failure, Repayment>> call({
    required String groupId,
    required String loanId,
    required double amount,
  }) {
    return repository.recordRepayment(groupId: groupId, loanId: loanId, amount: amount);
  }
}
