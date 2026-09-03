import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/shares_repository.dart';

class BuySharesUseCase {
  final SharesRepository repository;

  BuySharesUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    required String groupId,
    required String memberId,
    required int quantity,
  }) {
    return repository.purchaseShares(
      groupId: groupId,
      memberId: memberId,
      quantity: quantity,
    );
  }
}
