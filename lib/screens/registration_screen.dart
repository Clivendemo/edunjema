import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
//import 'package:firebase_auth/firebase_auth.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    try {
      print('[RegistrationScreen] Starting registration process...');
      print('[RegistrationScreen] Email: $email, Name: $name');

      // 1. Create user with email and password using AuthService
      final userCredential = await _authService.createUserWithEmailAndPassword(
        email,
        password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw 'User not created after registration.';
      }

      print('[RegistrationScreen] User created successfully, now saving profile...');

      // 2. Save additional user profile details (name) to Firestore
      await _firestoreService.saveUserProfile(
        userId: user.uid,
        name: name,
      );

      print('[RegistrationScreen] Profile saved successfully.');

      // NEW: Explicitly sign out the user after successful registration
      await _authService.signOut();
      print('[RegistrationScreen] User signed out after registration.');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful! Please log in with your new credentials.')), // MODIFIED message
        );

        // 3. After successful registration and sign-out, navigate back to the login screen
        context.go('/'); // Navigate back to the login screen
      }
    } catch (e) {
      print('[RegistrationScreen] Error during registration. Type: ${e.runtimeType}, Message: $e');

      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register for edunjema3'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Create Your Account',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        labelText: 'Your Name',
                        hintText: 'e.g., John Doe',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'your.email@example.com',
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty || !value.contains('@')) {
                          return 'Please enter a valid email address.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        hintText: 'Minimum 6 characters',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty || value.length < 6) {
                          return 'Password must be at least 6 characters long.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Re-enter your password',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password.';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _registerUser,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Register'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _isLoading ? null : () => context.go('/'),
                      child: Text(
                        'Already have an account? Login',
                        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
