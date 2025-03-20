import 'package:my_finance/features/home/domain/entities/expense.dart';

class ExpenseModel extends Expense {
  final String id;

  ExpenseModel({
    required this.id,
    required super.amount,
    required super.category,
    required super.date,
    super.description,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      category: json['category'],
      date: DateTime.parse(json['date']),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
    };
  }
}
