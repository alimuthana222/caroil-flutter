import 'dart:io';
import 'package:flutter/material.dart';
import 'package:oil_finder/services/supabase_auth_service.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
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

              SizedBox(height: 40),

              // App Title
              Text(
                'Car Oil Finder',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 16),

              Text(
                _isArabic()
                    ? 'اعثر على الزيت المناسب لسيارتك'
                    : 'Find the right oil for your car',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 60),

              // Primary Sign In Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _signIn,
                  icon: _isLoading
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  )
                      : Icon(_getSignInIcon()),
                  label: Text(_getSignInText()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Platform info
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.white70,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getPlatformInfo(),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40),

              // Benefits
              _buildBenefitsList(),

              SizedBox(height: 40),

              // Skip sign in option (for testing or guest access)
              TextButton(
                onPressed: _isLoading ? null : _showSkipDialog,
                child: Text(
                  _isArabic()
                      ? 'متابعة بدون تسجيل دخول'
                      : 'Continue without sign in',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isArabic() {
    return Localizations.localeOf(context).languageCode == 'ar';
  }

  Widget _buildBenefitsList() {
    final benefits = _isArabic()
        ? [
      'احفظ سجل تغيير الزيت',
      'زامن البيانات عبر الأجهزة',
      'تذكيرات تلقائية للصيانة',
      'تتبع عدة مركبات',
    ]
        : [
      'Save oil change records',
      'Sync data across devices',
      'Automatic maintenance reminders',
      'Track multiple vehicles',
    ];

    return Column(
      children: benefits.map((benefit) => Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.white70,
              size: 16,
            ),
            SizedBox(width: 8),
            Text(
              benefit,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  IconData _getSignInIcon() {
    if (Platform.isAndroid) {
      return Icons.g_mobiledata; // Google icon alternative
    } else if (Platform.isIOS) {
      return Icons.apple;
    }
    return Icons.login;
  }

  String _getSignInText() {
    if (_isLoading) {
      return _isArabic() ? 'جاري تسجيل الدخول...' : 'Signing in...';
    }

    if (Platform.isAndroid) {
      return _isArabic() ? 'تسجيل الدخول بـ Google' : 'Sign in with Google';
    } else if (Platform.isIOS) {
      return _isArabic() ? 'تسجيل الدخول بـ Apple' : 'Sign in with Apple';
    }
    return _isArabic() ? 'تسجيل الدخول' : 'Sign In';
  }

  String _getPlatformInfo() {
    if (Platform.isAndroid) {
      return _isArabic()
          ? 'سيتم استخدام حساب Google الخاص بك'
          : 'Your Google account will be used';
    } else if (Platform.isIOS) {
      return _isArabic()
          ? 'سيتم استخدام Apple ID الخاص بك'
          : 'Your Apple ID will be used';
    }
    return _isArabic()
        ? 'اختر طريقة تسجيل الدخول'
        : 'Choose sign in method';
  }

  // Main sign in method - uses native authentication
  Future<void> _signIn() async {
    setState(() => _isLoading = true);

    try {
      final result = await SupabaseAuthService.signIn();

      if (result?.user != null) {
        // Success - AuthWrapper will handle navigation
        print('✅ Sign in successful');
      } else {
        // User cancelled
        _showAlert(QuickAlertType.info, _isArabic()
            ? 'تم إلغاء تسجيل الدخول'
            : 'Sign in cancelled');
      }
    } catch (e) {
      print('❌ Sign in error: $e');

      String errorMessage = _getErrorMessage(e.toString());
      _showAlert(QuickAlertType.error, errorMessage);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('network') || error.contains('internet')) {
      return _isArabic()
          ? 'تحقق من اتصال الإنترنت وحاول مرة أخرى'
          : 'Check internet connection and try again';
    } else if (error.contains('cancelled') || error.contains('canceled')) {
      return _isArabic() ? 'تم إلغاء تسجيل الدخول' : 'Sign in cancelled';
    } else if (error.contains('invalid_grant')) {
      return _isArabic()
          ? 'انتهت صلاحية تسجيل الدخول، يرجى المحاولة مرة أخرى'
          : 'Session expired, please try again';
    } else if (error.contains('access_denied')) {
      return _isArabic()
          ? 'تم رفض الوصول. تأكد من منح الأذونات المطلوبة'
          : 'Access denied. Make sure to grant required permissions';
    } else if (error.contains('popup_closed')) {
      return _isArabic()
          ? 'تم إغلاق نافذة تسجيل الدخول'
          : 'Sign in window was closed';
    } else if (error.contains('google')) {
      return _isArabic()
          ? 'خطأ في تسجيل الدخول عبر Google. تأكد من تثبيت تطبيق Google'
          : 'Google sign in error. Make sure Google app is installed';
    } else if (error.contains('apple')) {
      return _isArabic()
          ? 'خطأ في تسجيل الدخول عبر Apple. تأكد من أن Apple ID يعمل بشكل صحيح'
          : 'Apple sign in error. Make sure Apple ID is working correctly';
    }
    return _isArabic()
        ? 'فشل في تسجيل الدخول. يرجى المحاولة مرة أخرى'
        : 'Sign in failed. Please try again';
  }

  void _showSkipDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isArabic()
            ? 'متابعة بدون تسجيل دخول'
            : 'Continue without sign in'),
        content: Text(_isArabic()
            ? 'يمكنك استخدام التطبيق بدون تسجيل دخول، لكن:\n\n'
            '• لن يتم حفظ بياناتك\n'
            '• لن تحصل على تذكيرات\n'
            '• لن تتمكن من مزامنة البيانات\n\n'
            'هل تريد المتابعة؟'
            : 'You can use the app without signing in, but:\n\n'
            '• Your data won\'t be saved\n'
            '• You won\'t get reminders\n'
            '• You can\'t sync data across devices\n\n'
            'Do you want to continue?'
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_isArabic() ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _enableGuestMode();
            },
            child: Text(_isArabic() ? 'متابعة' : 'Continue'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _enableGuestMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('guest_mode', true);

      // Navigate to main app
      Navigator.of(context).pushReplacementNamed('/');
    } catch (e) {
      _showAlert(
          QuickAlertType.error,
          _isArabic()
              ? 'خطأ في تفعيل وضع الضيف'
              : 'Error enabling guest mode'
      );
    }
  }

  void _showAlert(QuickAlertType type, String message) {
    if (mounted) {
      QuickAlert.show(
        context: context,
        type: type,
        text: message,
        confirmBtnText: _isArabic() ? 'موافق' : 'OK',
      );
    }
  }
}