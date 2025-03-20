import 'dart:async';
import 'package:my_finance/features/home/domain/entities/expense.dart';
import 'package:my_finance/features/home/domain/entities/monthly_data.dart';

abstract class HomeRepository {
  // Fetch data
  Future<double> getMonthlyIncome();
  Future<List<Expense>> getMonthlyExpenses();
  Future<List<MonthlyData>> getMonthlyData();

  // Stream data for real-time updates
  Stream<double> streamMonthlyIncome();
  Stream<List<Expense>> streamMonthlyExpenses();

  // Close any open streams
  void dispose();
}
