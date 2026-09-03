import '../../domain/entities/loan.dart';

double _d(dynamic v, [double def = 0]) {
  if (v == null) return def;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? def;
}

class LoanModel extends Loan {
  const LoanModel({
    required super.id,
    required super.groupId,
    required super.memberId,
    required super.principalAmount,
    required super.interestRate,
    required super.interestAmount,
    required super.totalRepayable,
    required super.amountPaid,
    required super.outstandingAmount,
    super.issueDate,
    super.dueDate,
    required super.status,
    super.notes,
    required super.memberName,
  });

  /// Maps the backend loan shape:
  /// { principal, interestRate, member:{name}, status, issueDate?, dueDate?,
  ///   totalRepaid, outstanding }
  factory LoanModel.fromJson(Map<String, dynamic> json) {
    final principal = _d(json['principal'] ?? json['principalAmount']);
    final rate = _d(json['interestRate']);
    final totalRepaid = _d(json['totalRepaid'] ?? json['amountPaid']);
    final interestAmount = principal * rate / 100;
    final totalRepayable = principal + interestAmount;
    final outstanding = json['outstanding'] != null
        ? _d(json['outstanding'])
        : (json['outstandingAmount'] != null
            ? _d(json['outstandingAmount'])
            : (totalRepayable - totalRepaid).clamp(0, double.infinity).toDouble());

    return LoanModel(
      id: json['id'] ?? '',
      groupId: json['groupId'] ?? '',
      memberId: json['memberId'] ?? '',
      principalAmount: principal,
      interestRate: rate,
      interestAmount: interestAmount,
      totalRepayable: totalRepayable,
      amountPaid: totalRepaid,
      outstandingAmount: outstanding,
      issueDate: json['issueDate'] != null ? DateTime.tryParse(json['issueDate']) : null,
      dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate']) : null,
      status: json['status'] ?? 'PENDING',
      notes: json['notes'],
      memberName: json['member']?['name'] ?? json['memberName'] ?? 'Unknown',
    );
  }
}
