import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../domain/entities/loan.dart';
import '../../domain/repositories/loans_repository.dart';
import '../datasources/loans_remote_datasource.dart';

class LoansRepositoryImpl implements LoansRepository {
  final LoansRemoteDataSource remoteDataSource;

  LoansRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Loan>>> getLoans(String groupId, {String? memberId, String? status}) async {
    try {
      final loans = await remoteDataSource.getLoans(groupId, memberId: memberId, status: status);
      return Right(loans);
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, Loan>> requestLoan({
    required String groupId,
    required String memberId,
    required double principalAmount,
    DateTime? dueDate,
    String? notes,
  }) async {
    try {
      final loan = await remoteDataSource.requestLoan(
        groupId: groupId,
        memberId: memberId,
        principalAmount: principalAmount,
        dueDate: dueDate?.toIso8601String(),
        notes: notes,
      );
      return Right(loan);
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, Loan>> approveLoan(String groupId, String loanId) async {
    try {
      return Right(await remoteDataSource.approveLoan(groupId, loanId));
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, Loan>> rejectLoan(String groupId, String loanId) async {
    try {
      return Right(await remoteDataSource.rejectLoan(groupId, loanId));
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }
}
