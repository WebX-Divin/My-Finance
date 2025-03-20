import 'package:my_finance/features/home/domain/entities/expense.dart';
import 'package:my_finance/features/home/domain/repository/home_repository.dart';

class GetMonthlyExpenses {
  final HomeRepository repository;

  GetMonthlyExpenses(this.repository);

  Future<double> execute() async {
    final expenses = await repository.getMonthlyExpenses();
    double total = 0.0;
    for (var expense in expenses) {
      total += expense.amount;
    }
    return total;
  }

  Future<Map<String, double>> executeByCategory() async {
    final expenses = await repository.getMonthlyExpenses();
    Map<String, double> categories = {};

    for (var expense in expenses) {
      final category = expense.category;
      if (categories.containsKey(category)) {
        categories[category] = (categories[category] ?? 0) + expense.amount;
      } else {
        categories[category] = expense.amount;
      }
    }

    return categories;
  }

  Stream<List<Expense>> stream() {
    return repository.streamMonthlyExpenses();
  }
}
