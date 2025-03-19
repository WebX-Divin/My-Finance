import 'package:my_finance/export.dart';
import 'package:my_finance/features/auth/presentation/pages/update_password_page.dart';

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

    // Check if this is a password recovery event
    if (event == AuthChangeEvent.passwordRecovery && session != null) {
      // Navigate to password update screen with the token
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => UpdatePasswordPage(
            accessToken: session.accessToken,
          ),
        ),
      );
    }
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'My Finance',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthChecker(),
    );
  }
}
