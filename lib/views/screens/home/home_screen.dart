import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homy/views/screens/auth_screens/login_screen.dart';

class HomeScreen extends StatelessWidget {
  final String userName; // اسم المستخدم (يتم تمريره عند تسجيل الدخول)

  const HomeScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الصفحة الرئيسية"),
        centerTitle: true,
        backgroundColor: const Color(0xFFc6ab7c),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // صورة ترحيبية
              Image.asset(
                'assets/images/welcome.png', // تأكد من إضافة صورة ترحيب إلى مجلد assets
                height: 150,
              ),
              const SizedBox(height: 20),

              // رسالة الترحيب
              Text(
                "مرحبًا بك، $userName!",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              Text(
                "نتمنى لك تجربة رائعة في التطبيق.",
                style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // زر تسجيل الخروج
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut(); // ✅ تسجيل خروج المستخدم من Firebase

                  // ✅ الانتقال إلى شاشة تسجيل الدخول واستبدال الصفحة الحالية
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  "تسجيل الخروج",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
