import 'dart:async';

import 'package:my_finance/features/home/data/datasource/home_remote_datasource.dart';
import 'package:my_finance/features/home/data/models/expense_model.dart';
import 'package:my_finance/features/home/data/models/income_model.dart';
import 'package:my_finance/features/home/domain/entities/expense.dart';
import 'package:my_finance/features/home/domain/entities/monthly_data.dart';
import 'package:my_finance/features/home/domain/repository/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  StreamSubscription<List<IncomeModel>>? _incomeSubscription;
  StreamSubscription<List<ExpenseModel>>? _expensesSubscription;

  final StreamController<double> _incomeController =
      StreamController<double>.broadcast();
  final StreamController<List<Expense>> _expensesController =
      StreamController<List<Expense>>.broadcast();

  HomeRepositoryImpl({required this.remoteDataSource}) {
    _setupStreams();
  }

  void _setupStreams() {
    // Set up income stream
    _incomeSubscription =
        remoteDataSource.streamMonthlyIncome().listen((incomes) {
      if (incomes.isNotEmpty) {
        _incomeController.add(incomes.last.amount);
      }
    });

    // Set up expenses stream
    _expensesSubscription =
        remoteDataSource.streamMonthlyExpenses().listen((expenses) {
      _expensesController.add(expenses);
    });
  }

  @override
  Future<double> getMonthlyIncome() async {
    final income = await remoteDataSource.getMonthlyIncome();
    return income?.amount ?? 0;
  }

  @override
  Future<List<Expense>> getMonthlyExpenses() async {
    final expenses = await remoteDataSource.getMonthlyExpenses();
    return expenses;
  }

  @override
  Future<List<MonthlyData>> getMonthlyData() async {
    final monthlyData = await remoteDataSource.getMonthlyData();
    return monthlyData;
  }

  @override
  Stream<double> streamMonthlyIncome() {
    return _incomeController.stream;
  }

  @override
  Stream<List<Expense>> streamMonthlyExpenses() {
    return _expensesController.stream;
  }

  @override
  void dispose() {
    _incomeSubscription?.cancel();
    _expensesSubscription?.cancel();
    _incomeController.close();
    _expensesController.close();
  }
}
