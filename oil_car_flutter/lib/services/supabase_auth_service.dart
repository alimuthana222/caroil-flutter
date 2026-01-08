import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:oil_finder/config/supabase_config.dart';

class SupabaseAuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // نبني GoogleSignIn ديناميكياً مع serverClientId
  static GoogleSignIn _buildGoogle() {
    return GoogleSignIn(
      scopes: const ['email', 'profile'],
      serverClientId: SupabaseConfig.googleWebClientId,
      clientId: (Platform.isAndroid && SupabaseConfig.googleAndroidClientId.isNotEmpty)
          ? SupabaseConfig.googleAndroidClientId
          : null,
    );
  }

  static User? get currentUser => _supabase.auth.currentUser;
  static bool get isSignedIn => currentUser != null;
  static Session? get currentSession => _supabase.auth.currentSession;
  static bool get isAuthenticated => currentSession != null;
  static Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  static Future<void> initialize() async {
    try {
      await _buildGoogle().signInSilently();
      print('✅ [INIT] Silent Google attempt done');
    } catch (e) {
      print('⚠️ [INIT] Silent sign in failed: $e');
    }
  }

  static Future<AuthResponse?> signIn() async {
    if (Platform.isAndroid) return _signInWithGoogle();
    if (Platform.isIOS) return _signInWithApple();
    throw UnsupportedError('Unsupported platform');
  }

  static Future<AuthResponse?> _signInWithGoogle() async {
    final g = _buildGoogle();
    try {
      print('🔐 [GOOGLE] Start sign-in');
      print('    serverClientId (Web) = ${SupabaseConfig.googleWebClientId}');
      print('    android clientId = ${SupabaseConfig.googleAndroidClientId.isEmpty ? "(empty)" : SupabaseConfig.googleAndroidClientId}');

      final acc = await g.signIn();
      if (acc == null) {
        print('❌ [GOOGLE] User cancelled');
        return null;
      }
      print('✅ [GOOGLE] Account: ${acc.email}');

      final auth = await acc.authentication;

      if (auth.idToken == null) {
        print('❌ [GOOGLE] idToken is NULL');
        _diagnoseIdTokenNull();
        throw Exception('Google idToken null');
      }
      if (auth.accessToken == null) {
        print('❌ [GOOGLE] accessToken is NULL');
        throw Exception('Google accessToken null');
      }

      print('🔎 [GOOGLE] idToken length=${auth.idToken!.length}, accessToken length=${auth.accessToken!.length}');
      print('🔎 [GOOGLE] idToken first 35 chars: ${auth.idToken!.substring(0, 35)}');

      final res = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: auth.idToken!,
        accessToken: auth.accessToken!,
      );

      if (res.user != null) {
        await _ensureUserProfile(res.user!);
        print('✅ [SUPABASE] Session established for ${res.user!.email}');
      } else {
        print('⚠️ [SUPABASE] AuthResponse has no user');
      }

      return res;
    } catch (e) {
      print('❌ [GOOGLE] Sign-In error: $e');
      final es = e.toString();
      if (es.contains('ApiException: 10') || es.contains('DEVELOPER_ERROR')) {
        _diagnoseApi10();
      }
      rethrow;
    }
  }

  static Future<AuthResponse?> _signInWithApple() async {
    try {
      print('🔐 [APPLE] Start sign-in');
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final cred = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
        nonce: nonce,
      );

      if (cred.identityToken == null) {
        throw Exception('Apple identityToken null');
      }

      final res = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: cred.identityToken!,
        nonce: rawNonce,
      );

      if (res.user != null) {
        await _ensureUserProfile(res.user!, appleCredential: cred);
        print('✅ [APPLE] Success');
      }
      return res;
    } catch (e) {
      print('❌ [APPLE] Sign-In error: $e');
      rethrow;
    }
  }

  static void _diagnoseIdTokenNull() {
    print('🔎 [DIAG] idToken null =>');
    print('  • تأكد أن SupabaseConfig.googleWebClientId يحتوي Web Client ID الصحيح (الشكل: xxxxx.apps.googleusercontent.com).');
    print('  • لا تضع Android Client ID مكانه.');
    print('  • Web Client ID نفسه موجود في Supabase Dashboard مع Client Secret.');
    print('  • جرّب حساب Google آخر وجهاز/محاكي آخر.');
  }

  static void _diagnoseApi10() {
    print('🔎 [DIAG] ApiException: 10 (DEVELOPER_ERROR) checklist:');
    print('  1) applicationId في android/app/build.gradle = com.oilcaralimuthana.oil_car_flutter');
    print('  2) في Google Cloud Console: Android OAuth client => نفس package + نفس SHA-1 (من gradlew signingReport).');
    print('  3) SHA-1 صحيح (افحص أنه ليس SHA-256).');
    print('  4) serverClientId في الكود = Web Client ID (ليس Android).');
    print('  5) أعد تثبيت التطبيق بعد أي تعديل وانتظر 5 دقائق.');
    print('  6) استخدم Emulator بصورة Google Play (ليس AOSP).');
  }

  static Future<void> _ensureUserProfile(
      User user, {
        AuthorizationCredentialAppleID? appleCredential,
      }) async {
    try {
      final existing = await _supabase
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      final data = <String, dynamic>{
        'id': user.id,
        'email': user.email,
        'updated_at': DateTime.now().toIso8601String(),
      };

      String? displayName = user.userMetadata?['full_name'] ?? user.userMetadata?['name'];
      if (appleCredential != null) {
        final fn = appleCredential.givenName;
        final ln = appleCredential.familyName;
        final combined = '${fn ?? ''} ${ln ?? ''}'.trim();
        if (combined.isNotEmpty) displayName = combined;
      }
      if (displayName != null && displayName.isNotEmpty) {
        data['display_name'] = displayName;
      }

      final photo = user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'];
      if (photo != null) data['photo_url'] = photo;

      final provider = user.appMetadata?['provider'];
      if (provider != null) data['provider'] = provider;

      if (existing == null) {
        data['created_at'] = DateTime.now().toIso8601String();
        await _supabase.from('user_profiles').insert(data);
        print('✅ [PROFILE] Created');
      } else {
        data.remove('id');
        await _supabase.from('user_profiles').update(data).eq('id', user.id);
        print('✅ [PROFILE] Updated');
      }
    } catch (e) {
      print('⚠️ [PROFILE] ensure error: $e');
    }
  }

  static Future<void> signOut() async {
    try {
      print('🔐 [SIGN OUT] Start');
      try {
        await _buildGoogle().disconnect();
      } catch (_) {
        try {
          await _buildGoogle().signOut();
        } catch (_) {}
      }
      await _supabase.auth.signOut();
      print('✅ [SIGN OUT] Done');
    } catch (e) {
      print('❌ [SIGN OUT] Error: $e');
      rethrow;
    }
  }

  static Future<void> deleteAccount() async {
    try {
      final u = currentUser;
      if (u == null) throw Exception('No user');
      final id = u.id;
      await _supabase.from('oil_change_records').delete().eq('user_id', id);
      await _supabase.from('user_profiles').delete().eq('id', id);
      try {
        await _supabase.rpc('delete_user_account');
      } catch (e) {
        print('⚠️ [DELETE] RPC failed: $e');
      }
      await signOut();
      print('✅ [DELETE] Complete');
    } catch (e) {
      print('❌ [DELETE] Error: $e');
      rethrow;
    }
  }

  static Future<UserResponse> updateUser({
    String? email,
    String? password,
    Map<String, dynamic>? data,
  }) async {
    final res = await _supabase.auth.updateUser(
      UserAttributes(email: email, password: password, data: data),
    );
    if (res.user != null) await _ensureUserProfile(res.user!);
    return res;
  }

  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final u = currentUser;
      if (u == null) return null;
      return await _supabase.from('user_profiles').select().eq('id', u.id).maybeSingle();
    } catch (e) {
      print('❌ [PROFILE] get error: $e');
      return null;
    }
  }

  static Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    final u = currentUser;
    if (u == null) throw Exception('No user');
    updates['updated_at'] = DateTime.now().toIso8601String();
    await _supabase.from('user_profiles').update(updates).eq('id', u.id);
    print('✅ [PROFILE] Row updated');
  }

  static Future<AuthResponse> refreshSession() => _supabase.auth.refreshSession();

  // Helpers
  static String _generateNonce([int length = 32]) {
    const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final rand = Random.secure();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  static String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }
}