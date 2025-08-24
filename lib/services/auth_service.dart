import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_model.dart';

class AuthService {
  static SupabaseClient get _client => SupabaseConfig.client;

  // Get current user
  static User? get currentUser => _client.auth.currentUser;
  
  // Get auth state stream
  static Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Register new user
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone_number': phoneNumber,
        },
      );

      if (response.user != null) {
        // Create user profile in database
        await _createUserProfile(response.user!, fullName, phoneNumber);
      }

      return response;
    } catch (e) {
      throw AuthException('Registration failed: $e');
    }
  }

  /// Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw AuthException('Sign in failed: $e');
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw AuthException('Sign out failed: $e');
    }
  }

  /// Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw AuthException('Password reset failed: $e');
    }
  }

  /// Get user profile
  static Future<UserModel?> getUserProfile() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  /// Update user profile
  static Future<void> updateUserProfile(UserModel userModel) async {
    try {
      final user = currentUser;
      if (user == null) throw AuthException('User not authenticated');

      await _client
          .from('user_profiles')
          .update(userModel.toJson())
          .eq('id', user.id);
    } catch (e) {
      throw AuthException('Profile update failed: $e');
    }
  }

  /// Create user profile in database
  static Future<void> _createUserProfile(
    User user, 
    String fullName, 
    String? phoneNumber,
  ) async {
    try {
      final userModel = UserModel(
        id: user.id,
        email: user.email!,
        fullName: fullName,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
      );

      await _client
          .from('user_profiles')
          .insert(userModel.toJson());
    } catch (e) {
      print('Error creating user profile: $e');
      // Don't throw here as user is already created in auth
    }
  }

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Update password
  static Future<void> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw AuthException('Password update failed: $e');
    }
  }

  /// Update email
  static Future<void> updateEmail(String newEmail) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(email: newEmail),
      );
    } catch (e) {
      throw AuthException('Email update failed: $e');
    }
  }
}