import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String? role;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false; // For showing the loading indicator
  String _errorMessage = ''; // For displaying error messages

  // Login logic
  void loginUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        final response = await AuthService().login(
          emailController.text.trim(),
          passwordController.text,
        );

        setState(() {
          _isLoading = false;
        });

        if (response.containsKey('token')) {
          if (!mounted) return;
          final prefs = await SharedPreferences.getInstance();
          final userRole = prefs.getString('userRole');
          if (userRole == 'player') {
            Navigator.pushReplacementNamed(context, '/browse_futsals');
          } else if (userRole == 'futsal_owner') {
            Navigator.pushReplacementNamed(context, '/futsal_owner_dashboard');
          } else if (userRole == 'admin') {
            Navigator.pushReplacementNamed(context, '/admin_dashboard');
          }
        } else {
          setState(() {
            _errorMessage = response['message'] ?? 'Login failed';
          });
        }
      } catch (error) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Something went wrong. Please try again later.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Card(
            elevation: 12,
            color: const Color(0xFF1E1E1E),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFC107),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF2E2E2E),
                        prefixIcon: const Icon(Icons.email_outlined,
                            color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 18, horizontal: 16),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Email cannot be empty' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF2E2E2E),
                        prefixIcon:
                            const Icon(Icons.lock_outline, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 18, horizontal: 16),
                      ),
                      obscureText: true,
                      validator: (value) =>
                          value!.isEmpty ? 'Password cannot be empty' : null,
                    ),
                    const SizedBox(height: 16),
                    // DropdownButtonFormField(
                    //   dropdownColor: const Color(0xFF2E2E2E),
                    //   style: const TextStyle(color: Colors.white),
                    //   decoration: InputDecoration(
                    //     labelText: 'Role',
                    //     labelStyle: const TextStyle(color: Colors.grey),
                    //     filled: true,
                    //     fillColor: const Color(0xFF2E2E2E),
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(12),
                    //       borderSide: BorderSide.none,
                    //     ),
                    //     contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    //   ),
                    //   value: role,
                    //   items: const [
                    //     DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    //     DropdownMenuItem(value: 'futsal_owner', child: Text('Futsal Owner')),
                    //     DropdownMenuItem(value: 'player', child: Text('Player')),
                    //   ],
                    //   onChanged: (value) => setState(() => role = value as String),
                    //   validator: (value) => value == null ? 'Role is required' : null,
                    // ),
                    const SizedBox(height: 24),
                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : ElevatedButton(
                            onPressed: loginUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFC107),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(color: Colors.grey),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(
                                context, '/register');
                          },
                          child: const Text(
                            "Register",
                            style: TextStyle(
                              color: Color(0xFFFFC107),
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
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
