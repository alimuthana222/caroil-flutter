import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oil_finder/services/supabase_auth_service.dart';
import 'package:oil_finder/screens/sign_in_screen.dart';
import 'package:oil_finder/screens/vin_lookup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthWrapperScreen extends StatefulWidget {
  const AuthWrapperScreen({Key? key}) : super(key: key);

  @override
  State<AuthWrapperScreen> createState() => _AuthWrapperScreenState();
}

class _AuthWrapperScreenState extends State<AuthWrapperScreen> {
  bool? _isGuestMode;

  @override
  void initState() {
    super.initState();
    _checkGuestMode();
  }

  Future<void> _checkGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    final guestMode = prefs.getBool('guest_mode') ?? false;
    setState(() {
      _isGuestMode = guestMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isGuestMode == null) {
      return _buildLoadingScreen();
    }

    if (_isGuestMode!) {
      return VinLookupScreen(); // Guest mode - go directly to main app
    }

    return StreamBuilder<AuthState>(
      stream: SupabaseAuthService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading while determining auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        }

        // Check if user is authenticated
        final session = snapshot.data?.session;
        if (session != null && SupabaseAuthService.isSignedIn) {
          return VinLookupScreen(); // Main app screen
        } else {
          return SignInScreen(); // Sign in screen
        }
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.car_repair,
                size: 80,
                color: Colors.green,
              ),
            ),

            SizedBox(height: 30),

            Text(
              'Car Oil Finder',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 20),

            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),

            SizedBox(height: 20),

            Text(
              _isArabic() ? 'جاري التحميل...' : 'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isArabic() {
    return Localizations.localeOf(context).languageCode == 'ar';
  }
}