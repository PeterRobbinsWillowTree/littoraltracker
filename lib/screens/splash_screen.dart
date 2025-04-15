import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image container with fixed size
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
              child: Image.asset(
                'assets/images/splash.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20), // Spacing between image and text
            // App name text
            const Text(
              'Littoral Commander\nUnit Tracker',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4A4A),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 