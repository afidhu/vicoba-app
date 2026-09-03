import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/repayment.dart';

abstract class RepaymentsRepository {
  Future<Either<Failure, List<Repayment>>> getRepayments(String groupId, String loanId);
  Future<Either<Failure, Repayment>> recordRepayment({
    required String groupId,
    required String loanId,
    required double amount,
  });
}
