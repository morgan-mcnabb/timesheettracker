import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpResult {
  final User? user;
  final Session? session;

  SignUpResult({this.user, this.session});
}

class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;

  static Future<SignUpResult> signUp({
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

    return SignUpResult(user: response.user, session: response.session);
  }

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

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

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

  static Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
