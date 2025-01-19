// lib/pages/auth_page.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isSignUp = false; 
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String? _infoMessage;

  Future<void> _handleSubmit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _infoMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      if (_isSignUp) {
        final result = await AuthService.signUp(email: email, password: password);

        if (result.session == null) {
          setState((){
            _infoMessage = 
              'A confirmation link has been emailed to $email.\n'
              'Please verify your email, then sign in.';
          });
        }
      } else {
        await AuthService.signIn(email: email, password: password);
      }
      // Once signed in/signed up successfully, the `main.dart` auth listener
      // will detect the user change and navigate accordingly.
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isSignUp ? 'Sign Up' : 'Sign In'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: 400, // For web, or adapt as needed
            child: Column(
              children: [
                Text(
                  _isSignUp
                      ? 'Create a new account'
                      : 'Sign in to your account',
                  style: textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email, color: colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock, color: colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 16),

                // Display possible info messages (e.g., "Check your email...")
                if (_infoMessage != null) ...[
                  Text(
                    _infoMessage!,
                    style: const TextStyle(color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                ],

                // Display error messages
                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                ],

                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_isSignUp ? 'Sign Up' : 'Sign In'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isSignUp = !_isSignUp;
                      _infoMessage = null;
                      _errorMessage = null;
                    });
                  },
                  child: Text(
                    _isSignUp
                        ? 'Already have an account? Sign In'
                        : 'Don\'t have an account? Sign Up',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}