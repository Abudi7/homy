import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homy/views/screens/home/home_screen.dart';
import 'package:homy/views/screens/auth_screens/login_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // ✅ Show loading while checking auth state
          }

          if (snapshot.hasData && snapshot.data != null) {
            final User user = snapshot.data!;
            final String userName = user.displayName ?? user.email ?? "مستخدم";
            return HomeScreen(userName: userName); // ✅ Navigate to HomeScreen
          } else {
            return const LoginScreen(); // ✅ Navigate to LoginScreen if user is not logged in
          }
        },
      ),
    );
  }
}
