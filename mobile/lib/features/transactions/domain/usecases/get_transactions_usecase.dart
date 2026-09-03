import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';
import '../repositories/transactions_repository.dart';

class GetTransactionsUseCase {
  final TransactionsRepository repository;
  GetTransactionsUseCase(this.repository);
  Future<Either<Failure, List<Transaction>>> call(String groupId, {String? memberId, String? type}) {
    return repository.getTransactions(groupId, memberId: memberId, type: type);
  }
}
