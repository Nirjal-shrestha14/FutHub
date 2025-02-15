import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
  "FUTHUB",
  style: TextStyle(
    fontSize: 28, // Increased size for better visibility
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 2,
    fontFamily: 'CustomFont', // Ensure this matches the family name in pubspec.yaml
  ),
),

                const SizedBox(height: 20),
                const Text(
                  "MATCHDAY",
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 30),
                Image.asset(
                  'assets/kicking_player.png', // Ensure this image is in your assets folder
                  width: 300,
                ),
                const SizedBox(height: 30),
                const Text(
                  "HOME VS AWAY",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register'); // Ensure this route exists
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "GET STARTED",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
