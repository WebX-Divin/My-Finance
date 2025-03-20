import 'package:my_finance/export.dart';
import 'package:my_finance/features/auth/presentation/pages/update_password_page.dart';
import 'package:my_finance/features/home/data/datasource/home_remote_datasource.dart';
import 'package:my_finance/features/home/data/repository/home_repository_impl.dart';
import 'package:my_finance/features/home/domain/repository/home_repository.dart';
import 'package:my_finance/features/home/domain/usecase/expense_usecase.dart';
import 'package:my_finance/features/home/domain/usecase/income_usecase.dart';
import 'package:my_finance/features/home/domain/usecase/monthly_data_usecase.dart';
import 'package:my_finance/features/home/domain/usecase/transaction_usecase.dart';
import 'package:my_finance/features/home/presentation/providers/home_provider.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://teyfgqnznfzkxigankiv.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRleWZncW56bmZ6a3hpZ2Fua2l2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIzNDMyNTUsImV4cCI6MjA1NzkxOTI1NX0.h5Pxdo-U2npXVcH1eUNojg3HQQ8PeiFMDXnby2vwsM4',
  );

  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final session = data.session;
    final event = data.event;

    if (event == AuthChangeEvent.passwordRecovery && session != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => UpdatePasswordPage(
            accessToken: session.accessToken,
          ),
        ),
      );
    }
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<HomeRemoteDataSource>(
          create: (context) =>
              HomeRemoteDataSource(supabase: Supabase.instance.client),
        ),
        Provider<HomeRepository>(
          create: (context) => HomeRepositoryImpl(
              remoteDataSource: context.read<HomeRemoteDataSource>()),
        ),
        ChangeNotifierProvider<HomeProvider>(
          create: (context) => HomeProvider(
            getMonthlyIncome: GetMonthlyIncome(context.read<HomeRepository>()),
            getMonthlyExpenses:
                GetMonthlyExpenses(context.read<HomeRepository>()),
            getRecentTransactions:
                GetRecentTransactions(context.read<HomeRepository>()),
            getMonthlyData: GetMonthlyData(context.read<HomeRepository>()),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'My Finance',
        navigatorKey: navigatorKey,
        theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const AuthChecker(),
      ),
    );
  }
}
