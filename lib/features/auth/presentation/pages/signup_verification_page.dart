import 'package:my_finance/export.dart';

class VerificationPage extends StatefulWidget {
  final String email;

  const VerificationPage({super.key, required this.email});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final supabase = Supabase.instance.client;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();

    // Listen for auth state changes
    supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;

      if (event == AuthChangeEvent.userUpdated) {
        final Session? session = data.session;
        final User? user = data.session?.user;

        if (user != null && session != null && user.emailConfirmedAt != null) {
          // Email has been confirmed, navigate to home screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      }
    });
  }

  Future<void> _checkEmailConfirmation() async {
    setState(() {
      _isChecking = true;
    });

    try {
      // Refresh the session to check if email has been confirmed
      await supabase.auth.refreshSession();

      final user = supabase.auth.currentUser;

      if (user != null && user.emailConfirmedAt != null) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Email not verified yet. Please check your inbox.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking email verification status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.email,
              size: 80,
              color: Colors.blue,
            ),
            SizedBox(height: 20),
            Text(
              'Verification Email Sent',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'We\'ve sent a verification email to:',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              widget.email,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            Text(
              'Please check your inbox and click on the verification link to complete the signup process.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isChecking ? null : _checkEmailConfirmation,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: _isChecking
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('I\'ve verified my email'),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // You could implement a resend verification email function here
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => SignUpPage()));
              },
              child: Text('Didn\'t receive the email? Resend'),
            ),
          ],
        ),
      ),
    );
  }
}
