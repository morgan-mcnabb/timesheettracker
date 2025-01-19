import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Sign up a new user with email and password.
  static Future<void> signUp({
    required String email,
    required String password,
  }) async {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

    if (response.user == null) {
      throw Exception("There was a problem signing in.");
    }
  }

  /// Sign in existing user with email and password.
  static Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null || response.session == null) {
      throw Exception("There was a problem signing in.");
    }
  }

  /// Sign out the currently logged-in user.
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Return the currently logged-in user (or null if none).
  static User? get _currentUser {
    return _client.auth.currentUser;
  }

  static User getCurrentUser() {
    final user = _currentUser;
    if (user == null) {
      throw Exception('No authenticated user found.');
    }
    return user;
  }

  /// Stream that notifies when authentication state changes.
  static Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
