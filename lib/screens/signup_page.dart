import 'package:flutter/material.dart';
import 'package:nhost_dart/nhost_dart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SignUpPage extends StatefulWidget {
  final NhostClient nhostClient;
  final FlutterSecureStorage secureStorage;

  const SignUpPage({
    Key? key,
    required this.nhostClient,
    required this.secureStorage,
  }) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    try {
      await widget.nhostClient.auth.signUp(
        email: email,
        password: password,
      );

      // Auto-login after successful sign-up
      final accessToken = widget.nhostClient.auth.accessToken;
      if (accessToken != null) {
        await widget.secureStorage.write(key: 'nhost_access_token', value: accessToken);
      }

      if (!mounted) return;
      
      // Navigate directly to home
      Navigator.of(context).pushReplacementNamed('/home');

    } catch (e) {
      // Handle sign-up errors
      var msg = 'Sign up failed';
      final errorMsg = e.toString().toLowerCase();

      if (errorMsg.contains('already') || errorMsg.contains('exists') || errorMsg.contains('duplicate')) {
        msg = 'This email is already registered. Please login instead.';
      } else if (errorMsg.contains('password') && (errorMsg.contains('weak') || errorMsg.contains('short'))) {
        msg = 'Password is too weak. Use at least 8 characters with letters and numbers.';
      } else if (errorMsg.contains('invalid email') || errorMsg.contains('email format')) {
        msg = 'Invalid email format.';
      } else if (errorMsg.contains('network') || errorMsg.contains('connection')) {
        msg = 'Network error. Please try again.';
      } else {
        msg = 'Sign up failed. Please try again.';
      }

      setState(() {
        _error = msg;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up - Antigravity')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.person_add_outlined, size: 80, color: Colors.blue),
                const SizedBox(height: 24),
                const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign up to get started',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Please enter email';
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outlined),
                          border: OutlineInputBorder(),
                          helperText: 'At least 8 characters',
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Please enter password';
                          if (v.length < 8) return 'Password must be at least 8 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: Icon(Icons.lock_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Please confirm password';
                          if (v != _passwordCtrl.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _signUp,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Sign Up', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  child: const Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
