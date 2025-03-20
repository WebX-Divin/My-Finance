import 'package:my_finance/core/utils/date_formatter.dart';
import 'package:my_finance/features/home/domain/entities/transaction.dart';
import 'package:my_finance/features/home/domain/repository/home_repository.dart';

class GetRecentTransactions {
  final HomeRepository repository;

  GetRecentTransactions(this.repository);

  Future<List<Transaction>> execute(int limit) async {
    final expenses = await repository.getMonthlyExpenses();

    // Sort expenses by date (newest first)
    expenses.sort((a, b) => b.date.compareTo(a.date));

    // Convert expenses to transactions (limited by count)
    final recentTransactions = expenses.take(limit).map((expense) {
      return Transaction(
        name: expense.category, // Using category as name for simplicity
        category: expense.category,
        amount: -expense.amount, // Negate for expenses
        date: DateFormatter.formatDate(expense.date),
      );
    }).toList();

    return recentTransactions;
  }
}
