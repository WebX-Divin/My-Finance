import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:my_finance/features/home/data/models/transaction_model.dart';
import 'package:my_finance/features/home/domain/entities/expense.dart';
import 'package:my_finance/features/home/domain/entities/monthly_data.dart';
import 'package:my_finance/features/home/domain/entities/transaction.dart';
import 'package:my_finance/features/home/domain/usecase/expense_usecase.dart';
import 'package:my_finance/features/home/domain/usecase/income_usecase.dart';
import 'package:my_finance/features/home/domain/usecase/monthly_data_usecase.dart';
import 'package:my_finance/features/home/domain/usecase/transaction_usecase.dart';

class HomeProvider extends ChangeNotifier {
  final GetMonthlyIncome _getMonthlyIncome;
  final GetMonthlyExpenses _getMonthlyExpenses;
  final GetRecentTransactions _getRecentTransactions;
  final GetMonthlyData _getMonthlyData;

  // Data state
  bool _isLoading = true;
  double _monthlyIncome = 0;
  double _monthlyExpenses = 0;
  Map<String, double> _expensesByCategory = {};
  List<Transaction> _recentTransactions = [];
  List<MonthlyData> _monthlyData = [];

  // Stream subscriptions
  StreamSubscription<double>? _incomeSubscription;
  StreamSubscription<List<Expense>>? _expensesSubscription;

  // Getters
  bool get isLoading => _isLoading;
  double get monthlyIncome => _monthlyIncome;
  double get monthlyExpenses => _monthlyExpenses;
  Map<String, double> get expensesByCategory => _expensesByCategory;
  List<Transaction> get recentTransactions => _recentTransactions;
  List<MonthlyData> get monthlyData => _monthlyData;
  double get netBalance => _monthlyIncome - _monthlyExpenses;

  HomeProvider({
    required GetMonthlyIncome getMonthlyIncome,
    required GetMonthlyExpenses getMonthlyExpenses,
    required GetRecentTransactions getRecentTransactions,
    required GetMonthlyData getMonthlyData,
  })  : _getMonthlyIncome = getMonthlyIncome,
        _getMonthlyExpenses = getMonthlyExpenses,
        _getRecentTransactions = getRecentTransactions,
        _getMonthlyData = getMonthlyData {
    loadData();
    _setupStreams();
  }

  void _setupStreams() {
    // Listen to income changes
    _incomeSubscription = _getMonthlyIncome.stream().listen((income) {
      _monthlyIncome = income;
      notifyListeners();
      // Refresh monthly data when income changes
      _fetchMonthlyData();
    });

    // Listen to expense changes
    _expensesSubscription = _getMonthlyExpenses.stream().listen((expenses) {
      _processExpenses(expenses);
      // Refresh monthly data when expenses change
      _fetchMonthlyData();
    });
  }

  void _processExpenses(List<Expense> expenses) async {
    // Calculate total expenses
    double totalExpenses = 0;
    Map<String, double> categories = {};

    for (var expense in expenses) {
      totalExpenses += expense.amount;

      // Group by category
      final category = expense.category;
      if (categories.containsKey(category)) {
        categories[category] = (categories[category] ?? 0) + expense.amount;
      } else {
        categories[category] = expense.amount;
      }
    }

    // Update state
    _monthlyExpenses = totalExpenses;
    _expensesByCategory = categories;

    // Update recent transactions
    _recentTransactions = await _getRecentTransactions.execute(4);

    notifyListeners();
  }

  Future<void> loadData() async {
    try {
      _isLoading = true;
      notifyListeners();

      await Future.wait([
        _fetchMonthlyIncome(),
        _fetchExpenses(),
        _fetchMonthlyData(),
        _fetchRecentTransactions(),
      ]);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading data: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchMonthlyIncome() async {
    _monthlyIncome = await _getMonthlyIncome.execute();
  }

  Future<void> _fetchExpenses() async {
    _monthlyExpenses = await _getMonthlyExpenses.execute();
    _expensesByCategory = await _getMonthlyExpenses.executeByCategory();
  }

  Future<void> _fetchRecentTransactions() async {
    _recentTransactions = await _getRecentTransactions.execute(4);
  }

  Future<void> _fetchMonthlyData() async {
    _monthlyData = await _getMonthlyData.execute();
    notifyListeners();
  }

  @override
  void dispose() {
    _incomeSubscription?.cancel();
    _expensesSubscription?.cancel();
    super.dispose();
  }

  void setRecentTransactions(List<TransactionModel> transactions) {}
}
