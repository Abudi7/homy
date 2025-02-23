// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance; // ✅ Firebase Authentication
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // ✅ Google Sign-In

  // ✅ دالة تسجيل الدخول عبر Google
  Future<UserCredential?> googleSignIn() async {
    try {
      // 1️⃣ بدء عملية تسجيل الدخول عبر Google
      final GoogleSignInAccount? gUser = await _googleSignIn.signIn();
      if (gUser == null) return null; // ✅ المستخدم ألغى تسجيل الدخول

      // 2️⃣ الحصول على بيانات المصادقة من Google
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // 3️⃣ إنشاء بيانات اعتماد تسجيل الدخول لـ Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // 4️⃣ تسجيل الدخول إلى Firebase باستخدام بيانات Google
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      // ✅ حفظ بيانات المستخدم في Firestore
      if (user != null) {
        final DocumentReference userDoc = FirebaseFirestore.instance.collection("users").doc(user.uid);
        final DocumentSnapshot userSnapshot = await userDoc.get();

        if (!userSnapshot.exists) {
          // ✅ إضافة بيانات المستخدم الجديدة إلى Firestore
          await userDoc.set({
            "firstName": gUser.displayName?.split(" ").first ?? "مستخدم",
            "lastName": gUser.displayName?.split(" ").last ?? "غير معروف",
            "email": user.email ?? "غير معروف",
            "profileImage": user.photoURL ?? "assets/images/profile/profile-image.png",
            "age": "غير محدد", // ✅ Google لا يوفر العمر تلقائيًا
            "address": "غير متوفر", // ✅ Google لا يوفر العنوان تلقائيًا
            "gender": "غير معروف", // ✅ Google لا يوفر الجنس
            "createdAt": FieldValue.serverTimestamp(),
          });
        }
      }

      return userCredential; // ✅ إرجاع بيانات المستخدم بعد تسجيل الدخول
    } catch (e) {
      print("⚠️ خطأ أثناء تسجيل الدخول عبر Google: $e"); // ✅ استخدام print بدلاً من debugPrint
      return null; // ✅ في حالة الخطأ، إرجاع `null`
    }
  }

  // ✅ دالة تسجيل الخروج من Google
  Future<void> googleSignOut() async {
    try {
      await _googleSignIn.signOut(); // ✅ تسجيل الخروج من Google
      await _auth.signOut(); // ✅ تسجيل الخروج من Firebase
    } catch (e) {
      print("⚠️ خطأ أثناء تسجيل الخروج: $e"); // ✅ استخدام print بدلاً من debugPrint
    }
  }
}
