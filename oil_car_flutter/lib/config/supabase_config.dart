class SupabaseConfig {
  // Replace with your actual Supabase URL and anon key
  static const String url = 'https://cwcgkhpuczfifpcbwsac.supabase.co';
  static const String anonKey = 'sb_publishable_3MXfUdXIwFkYLs2ek1fwog_8TgHje54';

  // OAuth redirect URLs for yo

  // Platform-specific OAuth providers
  static const String googleProvider = 'google';



  // Replace these with your real client IDs from Google Cloud Console.
  // Web client ID (the one marked "Web application")
  static const String googleWebClientId = '1012848051650-asof6gr2050eioft4ko4dpaoffcc2va0.apps.googleusercontent.com';
  // iOS client ID (the one marked iOS, bundle must match your app)

  // Optional: If you created an Android client ID and want to be explicit (not usually required
  // unless you need a specific behavior). Leave null or add when needed.
  static const String googleAndroidClientId = '1012848051650-c5a2l64p3imblhof81e84i2t3r72miom.apps.googleusercontent.com';

// If you later support desktop/web builds, you can reuse googleWebClientId where appropriate.
}