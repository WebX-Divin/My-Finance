import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_finance/features/home/data/models/transaction_model.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:my_finance/features/home/presentation/providers/home_provider.dart';
import 'package:my_finance/features/home/domain/repository/home_repository.dart';
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

  Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider.value(
          value: homeProvider,
          child: child,
        ),
      ),
    );
  }

  testWidgets('Displays "No recent transactions" when list is empty',
      (WidgetTester tester) async {
    expect(find.text('No recent transactions'), findsOneWidget);
  });

  testWidgets('Displays transactions correctly', (WidgetTester tester) async {
    final transactions = [
      TransactionModel(
          name: 'Lunch', amount: -10.0, category: 'Food', date: '2024-03-20'),
      TransactionModel(
          name: 'Salary',
          amount: 2000.0,
          category: 'Income',
          date: '2024-03-01'),
    ];

    await tester.pumpWidget(createTestWidget(RecentTransactionsWidget()));

    for (var transaction in transactions) {
      expect(find.text(transaction.name), findsOneWidget);
      expect(find.text(transaction.amount.toString()), findsOneWidget);
      expect(find.text(transaction.category), findsOneWidget);
    }
  });

  testWidgets('Displays monthly data correctly', (WidgetTester tester) async {
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
  });
}

class RecentTransactionsWidget extends StatelessWidget {
  const RecentTransactionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(); // Replace with actual widget implementation
  }
}
