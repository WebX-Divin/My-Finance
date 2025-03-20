import 'package:my_finance/features/home/domain/entities/monthly_data.dart';

class MonthlyDataModel extends MonthlyData {
  MonthlyDataModel({
    required super.month,
    required super.income,
    required super.expenses,
  });

  factory MonthlyDataModel.fromJson(Map<String, dynamic> json) {
    return MonthlyDataModel(
      month: json['month'],
      income: (json['income'] as num).toDouble(),
      expenses: (json['expenses'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'income': income,
      'expenses': expenses,
    };
  }
}
