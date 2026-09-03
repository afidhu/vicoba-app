import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/report_models.dart';

abstract class ReportsRemoteDataSource {
  Future<GroupFinancialSummaryModel> getFinancialSummary(
    String groupId, {
    String? startDate,
    String? endDate,
  });
  Future<MemberFinancialReportModel> getMemberReport(
    String groupId,
    String memberId,
  );
}

class ReportsRemoteDataSourceImpl implements ReportsRemoteDataSource {
  final Dio dio;
  ReportsRemoteDataSourceImpl({required this.dio});

  @override
  Future<GroupFinancialSummaryModel> getFinancialSummary(
    String groupId, {
    String? startDate,
    String? endDate,
  }) async {
    final response = await dio.get(
      ApiConstants.financialSummaryReport(groupId),
      queryParameters: {
        if (startDate != null) 'from': startDate,
        if (endDate != null) 'to': endDate,
      },
    );
    final data = Map<String, dynamic>.from(response.data as Map);
    // Enrich with share capital, which the summary endpoint doesn't include.
    try {
      final shares = await dio.get(ApiConstants.sharesReport(groupId));
      data['shares'] = shares.data;
    } catch (_) {}
    return GroupFinancialSummaryModel.fromJson(data);
  }

  @override
  Future<MemberFinancialReportModel> getMemberReport(
    String groupId,
    String memberId,
  ) async {
    // No dedicated endpoint; derive from per-member contributions + loans.
    final contributions = await dio.get(
      ApiConstants.contributions(groupId),
      queryParameters: {'memberId': memberId},
    );
    final loans = await dio.get(
      ApiConstants.loans(groupId),
      queryParameters: {'memberId': memberId},
    );
    double contribTotal = 0;
    for (final c in (contributions.data as List)) {
      contribTotal += double.tryParse(c['amount'].toString()) ?? 0;
    }
    double borrowed = 0;
    double repaid = 0;
    double outstanding = 0;
    for (final l in (loans.data as List)) {
      borrowed += double.tryParse(l['principal'].toString()) ?? 0;
      repaid += double.tryParse((l['totalRepaid'] ?? 0).toString()) ?? 0;
      outstanding += double.tryParse((l['outstanding'] ?? 0).toString()) ?? 0;
    }
    return MemberFinancialReportModel.fromJson({
      'contributions': {'total': contribTotal},
      'shares': {'totalValue': 0, 'totalQuantity': 0},
      'fines': {'totalOwed': 0, 'totalPaid': 0, 'balance': 0},
      'loans': {
        'totalBorrowed': borrowed,
        'totalRepaid': repaid,
        'outstandingBalance': outstanding,
      },
    });
  }
}
