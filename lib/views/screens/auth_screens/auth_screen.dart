import 'package:cloud_firestore/cloud_firestore.dart';
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
        stream: FirebaseAuth.instance.authStateChanges(), // ✅ متابعة حالة تسجيل الدخول
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // ✅ عرض مؤشر التحميل أثناء الفحص
          }

          if (snapshot.hasData && snapshot.data != null) {
            final User user = snapshot.data!;
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator()); // ✅ انتظار تحميل بيانات المستخدم
                }

                if (userSnapshot.hasData && userSnapshot.data != null) {
                  final userData = userSnapshot.data!;
                  final String userName = userData['firstName'] ?? user.email ?? "مستخدم";
                  final String profileImage = userData['profileImage'] ?? 'assets/images/profile/profile-image.png';

                  // ✅ تمرير الاسم والصورة الشخصية إلى الصفحة الرئيسية
                  return HomeScreen(userName: userName, profileImage: profileImage);
                } else {
                  return const LoginScreen(); // ✅ إعادة التوجيه إلى صفحة تسجيل الدخول في حال عدم العثور على البيانات
                }
              },
            );
          } else {
            return const LoginScreen(); // ✅ إعادة التوجيه إلى صفحة تسجيل الدخول إذا لم يكن المستخدم مسجلاً الدخول
          }
        },
      ),
    );
  }
}
