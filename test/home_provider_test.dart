import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:my_finance/features/home/data/models/transaction_model.dart';
import 'package:my_finance/features/home/domain/repository/home_repository.dart';
import 'package:my_finance/features/home/presentation/providers/home_provider.dart';

import 'package:my_finance/features/home/domain/usecase/income_usecase.dart';
import 'package:my_finance/features/home/domain/usecase/expense_usecase.dart';
import 'package:my_finance/features/home/domain/usecase/transaction_usecase.dart';
import 'package:my_finance/features/home/domain/usecase/monthly_data_usecase.dart';

// Create Mock classes
class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  late HomeProvider homeProvider;
  late MockHomeRepository mockHomeRepository;

  setUp(() {
    mockHomeRepository = MockHomeRepository();
    homeProvider = HomeProvider(
      getMonthlyIncome: GetMonthlyIncome(mockHomeRepository),
      getMonthlyExpenses: GetMonthlyExpenses(mockHomeRepository),
      getRecentTransactions: GetRecentTransactions(mockHomeRepository),
      getMonthlyData: GetMonthlyData(mockHomeRepository),
    );
  });
  test('Initial state is correct', () {
    expect(homeProvider.isLoading, false);
    expect(homeProvider.recentTransactions, isEmpty);
    expect(homeProvider.monthlyIncome, 0.0);
    expect(homeProvider.monthlyExpenses, 0.0);
    expect(homeProvider.monthlyData, []);
  });
  test('Returns correct transaction list', () {
    final transactions = [
      TransactionModel(
          name: 'Coffee', amount: -5.0, category: 'Food', date: '2024-03-20'),
      TransactionModel(
          name: 'Salary',
          amount: 1500.0,
          category: 'Income',
          date: '2024-03-01'),
    ];

    homeProvider.setRecentTransactions(transactions);

    expect(homeProvider.recentTransactions, isNotEmpty);
    expect(homeProvider.recentTransactions.length, 2);
    expect(homeProvider.recentTransactions[0].name, 'Coffee');
  });
}
