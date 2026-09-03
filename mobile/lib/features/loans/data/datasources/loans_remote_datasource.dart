import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/loan_model.dart';

abstract class LoansRemoteDataSource {
  Future<List<LoanModel>> getLoans(
    String groupId, {
    String? memberId,
    String? status,
  });
  Future<LoanModel> requestLoan({
    required String groupId,
    required String memberId,
    required double principalAmount,
    String? dueDate,
    String? notes,
  });
  Future<LoanModel> approveLoan(String groupId, String loanId);
  Future<LoanModel> rejectLoan(String groupId, String loanId);
}

class LoansRemoteDataSourceImpl implements LoansRemoteDataSource {
  final Dio dio;

  LoansRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<LoanModel>> getLoans(
    String groupId, {
    String? memberId,
    String? status,
  }) async {
    final response = await dio.get(
      ApiConstants.loans(groupId),
      queryParameters: {
        if (memberId != null) 'memberId': memberId,
        if (status != null) 'status': status,
      },
    );
    return (response.data as List)
        .map((l) => LoanModel.fromJson(l as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<LoanModel> requestLoan({
    required String groupId,
    required String memberId,
    required double principalAmount,
    String? dueDate,
    String? notes,
  }) async {
    final response = await dio.post(
      ApiConstants.requestLoan(groupId),
      data: {
        'memberId': memberId,
        'principal': principalAmount,
        if (dueDate != null) 'dueDate': dueDate,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
    return LoanModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<LoanModel> approveLoan(String groupId, String loanId) async {
    final response = await dio.patch(
      ApiConstants.approveLoan(groupId, loanId),
      data: const {},
    );
    return LoanModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<LoanModel> rejectLoan(String groupId, String loanId) async {
    final response = await dio.patch(ApiConstants.rejectLoan(groupId, loanId));
    return LoanModel.fromJson(response.data as Map<String, dynamic>);
  }
}
