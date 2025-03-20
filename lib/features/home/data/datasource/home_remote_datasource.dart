import 'dart:async';
import 'package:intl/intl.dart';
import 'package:my_finance/features/home/data/models/expense_model.dart';
import 'package:my_finance/features/home/data/models/income_model.dart';
import 'package:my_finance/features/home/data/models/monthly_data_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeRemoteDataSource {
  final SupabaseClient supabase;

  HomeRemoteDataSource({required this.supabase});

  // Get monthly income
  Future<IncomeModel?> getMonthlyIncome() async {
    final response = await supabase
        .from('monthly_income')
        .select()
        .order('created_at', ascending: false)
        .limit(1);

    if (response.isNotEmpty) {
      return IncomeModel.fromJson(response[0]);
    }
    return null;
  }

  // Get monthly expenses
  Future<List<ExpenseModel>> getMonthlyExpenses() async {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);

    final response = await supabase
        .from('expenses')
        .select()
        .gte('date', firstDayOfMonth.toIso8601String())
        .order('date', ascending: false);

    return response
        .map<ExpenseModel>((expense) => ExpenseModel.fromJson(expense))
        .toList();
  }

  // Stream monthly income changes
  Stream<List<IncomeModel>> streamMonthlyIncome() {
    return supabase.from('monthly_income').stream(primaryKey: ['id']).map(
        (data) => data
            .map<IncomeModel>((income) => IncomeModel.fromJson(income))
            .toList());
  }

  // Stream monthly expenses changes
  Stream<List<ExpenseModel>> streamMonthlyExpenses() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);

    return supabase
        .from('expenses')
        .stream(primaryKey: ['id'])
        .gte('date', firstDayOfMonth.toIso8601String())
        .map((data) => data
            .map<ExpenseModel>((expense) => ExpenseModel.fromJson(expense))
            .toList());
  }

  // Get monthly data for chart (last 6 months)
  Future<List<MonthlyDataModel>> getMonthlyData() async {
    final now = DateTime.now();
    List<MonthlyDataModel> monthlyData = [];

    for (int i = 5; i >= 0; i--) {
      final month = now.month - i <= 0 ? now.month - i + 12 : now.month - i;
      final year = now.month - i <= 0 ? now.year - 1 : now.year;

      final firstDay = DateTime(year, month, 1);
      final lastDay =
          month == 12 ? DateTime(year + 1, 1, 0) : DateTime(year, month + 1, 0);

      // Get income for this month
      final incomeResponse = await supabase
          .from('monthly_income')
          .select()
          .eq('month', DateFormat('MMMM').format(firstDay))
          .limit(1);

      // Get expenses for this month
      final expenseResponse = await supabase
          .from('expenses')
          .select()
          .gte('date', firstDay.toIso8601String())
          .lte('date', lastDay.toIso8601String());

      double monthIncome = 0;
      if (incomeResponse.isNotEmpty) {
        monthIncome = (incomeResponse[0]['amount'] as num).toDouble();
      }

      double monthExpenses = 0;
      if (expenseResponse.isNotEmpty) {
        for (var expense in expenseResponse) {
          monthExpenses += (expense['amount'] as num).toDouble();
        }
      }

      monthlyData.add(MonthlyDataModel(
        month: DateFormat('MMM').format(firstDay),
        income: monthIncome,
        expenses: monthExpenses,
      ));
    }

    return monthlyData;
  }
}
