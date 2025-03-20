import 'package:my_finance/features/home/domain/entities/income.dart';

class IncomeModel extends Income {
  final String id;

  IncomeModel({
    required this.id,
    required super.amount,
    required super.month,
    required super.createdAt,
  });

  factory IncomeModel.fromJson(Map<String, dynamic> json) {
    return IncomeModel(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      month: json['month'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'month': month,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
