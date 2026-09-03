import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/loan.dart';
import '../repositories/loans_repository.dart';

class GetLoansUseCase {
  final LoansRepository repository;
  GetLoansUseCase(this.repository);
  Future<Either<Failure, List<Loan>>> call(String groupId, {String? memberId, String? status}) {
    return repository.getLoans(groupId, memberId: memberId, status: status);
  }
}

class RequestLoanUseCase {
  final LoansRepository repository;
  RequestLoanUseCase(this.repository);
  Future<Either<Failure, Loan>> call({
    required String groupId,
    required String memberId,
    required double principalAmount,
    DateTime? dueDate,
    String? notes,
  }) {
    return repository.requestLoan(
      groupId: groupId,
      memberId: memberId,
      principalAmount: principalAmount,
      dueDate: dueDate,
      notes: notes,
    );
  }
}

class ApproveLoanUseCase {
  final LoansRepository repository;
  ApproveLoanUseCase(this.repository);
  Future<Either<Failure, Loan>> call(String groupId, String loanId) {
    return repository.approveLoan(groupId, loanId);
  }
}

class RejectLoanUseCase {
  final LoansRepository repository;
  RejectLoanUseCase(this.repository);
  Future<Either<Failure, Loan>> call(String groupId, String loanId) {
    return repository.rejectLoan(groupId, loanId);
  }
}
