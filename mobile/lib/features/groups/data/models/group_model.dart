import '../../domain/entities/group.dart';

class GroupModel extends Group {
  const GroupModel({
    required super.id,
    required super.name,
    super.location,
    super.meetingDay,
    super.weeklyContribution = 0.0,
    super.sharePrice = 10000.0,
    super.fineDefaultAmount = 0.0,
    super.loanInterestRate = 0.0,
    super.memberCount = 0,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    int count = 0;
    if (json['_count'] != null && json['_count']['members'] != null) {
      count = (json['_count']['members'] as num).toInt();
    } else if (json['members'] != null && json['members'] is List) {
      count = (json['members'] as List).length;
    }

    return GroupModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'],
      meetingDay: json['meetingDay'],
      weeklyContribution: (json['weeklyContribution'] is num)
          ? (json['weeklyContribution'] as num).toDouble()
          : (double.tryParse(json['weeklyContribution']?.toString() ?? '0') ?? 0.0),
      sharePrice: (json['sharePrice'] is num)
          ? (json['sharePrice'] as num).toDouble()
          : (double.tryParse(json['sharePrice']?.toString() ?? '10000') ?? 10000.0),
      fineDefaultAmount: (json['fineDefaultAmount'] is num)
          ? (json['fineDefaultAmount'] as num).toDouble()
          : (double.tryParse(json['fineDefaultAmount']?.toString() ?? '0') ?? 0.0),
      loanInterestRate: (json['loanInterestRate'] is num)
          ? (json['loanInterestRate'] as num).toDouble()
          : (double.tryParse(json['loanInterestRate']?.toString() ?? '0') ?? 0.0),
      memberCount: count,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'name': name,
      if (location != null) 'location': location,
      if (meetingDay != null) 'meetingDay': meetingDay,
      'weeklyContribution': weeklyContribution,
      'sharePrice': sharePrice,
      'fineDefaultAmount': fineDefaultAmount,
      'loanInterestRate': loanInterestRate,
    };
  }
}
