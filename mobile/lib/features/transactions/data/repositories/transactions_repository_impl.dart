import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transactions_repository.dart';
import '../datasources/transactions_remote_datasource.dart';

class TransactionsRepositoryImpl implements TransactionsRepository {
  final TransactionsRemoteDataSource remoteDataSource;
  TransactionsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions(String groupId, {String? memberId, String? type}) async {
    try {
      final transactions = await remoteDataSource.getTransactions(groupId, memberId: memberId, type: type);
      return Right(transactions);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Failed to load transactions'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
