import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    Future.delayed(const Duration(seconds: 3), () {
      if (token == null || token.isEmpty) {
        Navigator.pushReplacementNamed(context, '/landing');
      } else {
        final userRole = prefs.getString('userRole');
        debugPrint('User Role: $userRole');
        if (userRole == "player") {
          Navigator.pushReplacementNamed(context, '/browse_futsals');
        } else if (userRole == "futsal_owner") {
          Navigator.pushReplacementNamed(context, '/futsal_owner_dashboard');
        } else if (userRole == "admin") {
          Navigator.pushReplacementNamed(context, '/admin_dashboard');
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading...',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
