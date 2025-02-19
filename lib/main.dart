import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:homy/firebase_options.dart';
import 'package:homy/views/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ Ensure Flutter is ready before Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // ✅ Initialize Firebase before running the app

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Homy App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SplashScreen(), // ✅ Start with the Splash Screen
    );
  }
}
