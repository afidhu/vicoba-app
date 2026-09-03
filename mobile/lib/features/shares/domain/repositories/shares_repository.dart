import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/shares_summary.dart';

abstract class SharesRepository {
  Future<Either<Failure, SharesSummary>> getSharesSummary(String groupId);
  Future<Either<Failure, Map<String, dynamic>>> purchaseShares({
    required String groupId,
    required String memberId,
    required int quantity,
  });
}
