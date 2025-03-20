import 'package:my_finance/core/utils/constants.dart';
import 'package:my_finance/export.dart';

class Profile extends StatelessWidget {
  final supabase = Supabase.instance.client;
  Profile({super.key});

  @override

  /// Returns a Scaffold with a centered Container that contains information about the user, such as
  /// their email and a "Sign Out" button. The user information is displayed in a Column with the
  /// following widgets:
  ///
  /// 1. A CircleAvatar with the user's email as the text.
  /// 2. A Text widget with the user's email.
  /// 3. A Text widget with the user's role.
  /// 4. An ElevatedButton with the label "Sign Out".
  ///
  /// The Container is given a white background color and a circular border radius of 16.
  /// The BoxShadow is given a color of black with an opacity of 0.05, a blur radius of 10, and an
  /// offset of (0, 5).
  ///
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Add Expenses',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Center(
        child: Container(
          width: 300,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: primaryColor.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: primaryColor,
                ),
              ),
              SizedBox(height: 16),
              Text(
                supabase.auth.currentUser?.email ?? 'User',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Premium Member',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _signOut(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _signOut(BuildContext context) async {
    await supabase.auth.signOut();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignUpPage()),
    );
  }
}
