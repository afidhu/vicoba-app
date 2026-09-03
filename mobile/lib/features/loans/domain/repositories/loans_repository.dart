import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/loan.dart';

abstract class LoansRepository {
  Future<Either<Failure, List<Loan>>> getLoans(String groupId, {String? memberId, String? status});
  Future<Either<Failure, Loan>> requestLoan({
    required String groupId,
    required String memberId,
    required double principalAmount,
    DateTime? dueDate,
    String? notes,
  });
  Future<Either<Failure, Loan>> approveLoan(String groupId, String loanId);
  Future<Either<Failure, Loan>> rejectLoan(String groupId, String loanId);
}
