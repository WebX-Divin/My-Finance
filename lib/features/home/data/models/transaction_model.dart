import 'package:my_finance/features/home/data/models/expense_model.dart';
import 'package:my_finance/features/home/domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  TransactionModel({
    required super.name,
    required super.category,
    required super.amount,
    required super.date,
  });

  factory TransactionModel.fromExpense(
      ExpenseModel expense, String formattedDate) {
    return TransactionModel(
      name: expense.category, // Using category as name for simplicity
      category: expense.category,
      amount: -expense.amount, // Negate for expenses
      date: formattedDate,
    );
  }
}
