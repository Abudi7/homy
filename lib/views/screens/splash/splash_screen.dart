import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:homy/views/screens/auth_screens/auth_screen.dart';
import 'package:homy/firebase_options.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeFirebaseAndNavigate();
  }

  // ✅ Function to initialize Firebase and navigate to AuthScreen
  Future<void> _initializeFirebaseAndNavigate() async {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // ✅ Ensure Firebase is initialized
      await Future.delayed(const Duration(seconds: 3)); // ✅ Show splash for 3 seconds
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      }
    } catch (e) {
      debugPrint("❌ Firebase initialization failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple, // Background color for splash
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            Image.asset(
              'assets/images/logo.png', // Ensure the logo is added in assets
              height: 120,
            ),
            const SizedBox(height: 20),

            // Welcome text
            const Text(
              "مرحبًا بك في Homy!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),

            // Subtext
            const Text(
              "جاري التحقق من تسجيل الدخول...",
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),

            const SizedBox(height: 30),
            // Loading indicator
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
