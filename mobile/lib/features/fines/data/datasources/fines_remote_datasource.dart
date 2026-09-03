import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/fine_model.dart';

abstract class FinesRemoteDataSource {
  Future<List<FineModel>> getFines(String groupId, {String? memberId, String? status});
  Future<FineModel> recordFine({
    required String groupId,
    required String memberId,
    required String reason,
    double? amount,
  });
  Future<FineModel> updateFineStatus({
    required String groupId,
    required String fineId,
    required String status,
  });
}

class FinesRemoteDataSourceImpl implements FinesRemoteDataSource {
  final Dio dio;

  FinesRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<FineModel>> getFines(String groupId, {String? memberId, String? status}) async {
    final response = await dio.get(
      ApiConstants.fines(groupId),
      queryParameters: {
        if (memberId != null) 'memberId': memberId,
        if (status != null) 'status': status,
      },
    );
    return (response.data as List)
        .map((f) => FineModel.fromJson(f as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<FineModel> recordFine({
    required String groupId,
    required String memberId,
    required String reason,
    double? amount,
  }) async {
    final response = await dio.post(
      ApiConstants.fines(groupId),
      data: {
        'memberId': memberId,
        'reason': reason,
        if (amount != null) 'amount': amount,
      },
    );
    return FineModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<FineModel> updateFineStatus({
    required String groupId,
    required String fineId,
    required String status,
  }) async {
    final response = await dio.patch(
      ApiConstants.updateFineStatus(groupId, fineId),
      data: {'status': status},
    );
    return FineModel.fromJson(response.data as Map<String, dynamic>);
  }
}
