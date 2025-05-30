// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homy/views/screens/auth_screens/register_screen.dart';
import 'package:homy/views/screens/home/home_screen.dart';
import 'package:homy/services/auth_services.dart'; // ✅ استيراد خدمة تسجيل الدخول عبر Google

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey =
      GlobalKey<FormState>(); // ✅ مفتاح النموذج للتحقق من صحة الإدخال
  final FirebaseAuth _auth = FirebaseAuth.instance; // ✅ Firebase Authentication

  String? email; // ✅ متغير لتخزين البريد الإلكتروني
  String? password; // ✅ متغير لتخزين كلمة المرور

  bool isLoading = false; // ✅ متغير لحالة التحميل عند تسجيل الدخول

  // ✅ دالة تسجيل الدخول عبر Firebase
  Future<void> signUser() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => isLoading = true);

    try {
      // ✅ تنفيذ تسجيل الدخول
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email!,
        password: password!,
      );

      // ✅ تحميل بيانات المستخدم من Firestore
      DocumentSnapshot userData =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();

      if (!mounted) return; // ✅ حل المشكلة

      String userName = userData['firstName'] ?? email!;
      String profileImage =
          userData['profileImage'] ?? "assets/images/profile/profile-image.png";

      // ✅ الانتقال إلى الصفحة الرئيسية
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  HomeScreen(userName: userName, profileImage: profileImage),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return; // ✅ حل المشكلة

      String errorMessage = "حدث خطأ أثناء تسجيل الدخول";
      if (e.code == 'user-not-found') {
        errorMessage = "البريد الإلكتروني غير مسجل";
      } else if (e.code == 'wrong-password') {
        errorMessage = "كلمة المرور غير صحيحة";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage, textAlign: TextAlign.center)),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ✅ دالة استعادة كلمة المرور
  Future<void> resetPassword() async {
    TextEditingController emailController = TextEditingController();
    bool isProcessing = false;

    await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text("استعادة كلمة المرور"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "أدخل بريدك الإلكتروني",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (isProcessing) const SizedBox(height: 10),
                    if (isProcessing) const CircularProgressIndicator(),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      if (!isProcessing) Navigator.pop(context);
                    },
                    child: const Text("إلغاء"),
                  ),
                  TextButton(
                    onPressed: () async {
                      setState(() => isProcessing = true);

                      String email = emailController.text.trim();

                      if (email.isEmpty) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("يرجى إدخال البريد الإلكتروني"),
                            ),
                          );
                        }
                        setState(() => isProcessing = false);
                        return;
                      }

                      try {
                        await _auth.sendPasswordResetEmail(email: email);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "تم إرسال رابط استعادة كلمة المرور إلى بريدك الإلكتروني",
                                style: TextStyle(
                                  color: Colors.white, // ✅ جعل النص أبيض
                                  fontWeight:
                                      FontWeight.bold, // ✅ زيادة سمك الخط
                                ),
                              ),
                              backgroundColor: const Color(
                                0xFFc6ab7c,
                              ), // ✅ لون الخلفية حسب ثيم التطبيق
                              behavior:
                                  SnackBarBehavior
                                      .floating, // ✅ جعلها عائمة للحصول على تصميم أفضل
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  12,
                                ), // ✅ حواف مستديرة
                              ),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ), // ✅ ضبط الهامش
                              duration: const Duration(
                                seconds: 3,
                              ), // ✅ مدة ظهور الرسالة
                            ),
                          );
                        }

                        // ✅ تأخير الخروج من الـ Dialog بعد استعادة الباسورد
                        Future.delayed(Duration.zero, () {
                          if (mounted) Navigator.pop(context);
                        });
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                "حدث خطأ، تأكد من صحة البريد الإلكتروني",
                                style: TextStyle(
                                  color: Colors.white,
                                ), // ✅ نص أبيض ليتناسب مع اللون الغامق
                                textAlign: TextAlign.center, // ✅ توسيط النص
                              ),
                              backgroundColor: const Color(
                                0xFFc6ab7c,
                              ), // ✅ استبدال اللون بلون شعار التطبيق
                              behavior:
                                  SnackBarBehavior
                                      .floating, // ✅ يجعل التنبيه عائمًا وليس ملتصقًا بأسفل الشاشة
                              margin: const EdgeInsets.all(16), // ✅ إضافة هوامش
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  12,
                                ), // ✅ حواف دائرية جميلة
                              ),
                              duration: const Duration(
                                seconds: 3,
                              ), // ✅ ضبط مدة العرض
                            ),
                          );
                        }
                      }

                      setState(() => isProcessing = false);
                    },
                    child: const Text("إرسال"),
                  ),
                ],
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // ✅ دعم اتجاه النص من اليمين إلى اليسار
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey, // ✅ مفتاح النموذج للتحقق من الإدخال
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 50),
                Image.asset(
                  'assets/images/logo.png', // ✅ صورة شعار التطبيق
                  height: 300,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),
                Text(
                  "تسجيل الدخول إلى حسابك",
                  style: GoogleFonts.tajawal(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // ✅ حقل إدخال البريد الإلكتروني
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال البريد الإلكتروني';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'يرجى إدخال بريد إلكتروني صالح';
                    }
                    return null;
                  },

                  onSaved: (value) => email = value,
                ),
                const SizedBox(height: 16),

                // ✅ حقل إدخال كلمة المرور
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال كلمة المرور';
                    }
                    if (value.length < 6) {
                      return 'يجب أن تكون كلمة المرور مكونة من 6 أحرف على الأقل';
                    }
                    return null;
                  },

                  onSaved: (value) => password = value,
                ),
                const SizedBox(height: 20),
                // ✅ زر "نسيت كلمة المرور؟"
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: resetPassword,
                    child: Text(
                      "نسيت كلمة المرور؟",
                      style: GoogleFonts.tajawal(
                        // ✅ تطبيق خط تاجوال
                        color: const Color(
                          0xFFc6ab7c,
                        ), // ✅ لون النص حسب ثيم التطبيق
                        fontWeight: FontWeight.bold, // ✅ جعل الخط أكثر وضوحًا
                        fontSize: 16, // ✅ ضبط الحجم ليكون متناسقًا مع التصميم
                      ),
                    ),
                  ),
                ),

                // ✅ زر تسجيل الدخول
                ElevatedButton(
                  onPressed:
                      isLoading ? null : signUser, // ✅ تعطيل الزر أثناء التحميل
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(
                      const Color(0xFFc6ab7c),
                    ),
                  ),
                  child:
                      isLoading
                          ? const CircularProgressIndicator(
                            color: Colors.white,
                          ) // ✅ مؤشر تحميل أثناء تسجيل الدخول
                          : Text(
                            'تسجيل الدخول',
                            style: GoogleFonts.tajawal(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                ),
                const SizedBox(height: 20),
                // ✅ أزرار تسجيل الدخول باستخدام جوجل وفيسبوك
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        GoogleAuthService googleAuth = GoogleAuthService();
                        UserCredential? userCredential =
                            await googleAuth.googleSignIn();

                        if (userCredential != null) {
                          // ✅ الانتقال إلى الصفحة الرئيسية بعد نجاح تسجيل الدخول
                          Navigator.pushReplacement(
                            // ignore:
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => HomeScreen(
                                    userName:
                                        userCredential.user!.displayName ??
                                        "مستخدم",
                                    profileImage:
                                        userCredential.user!.photoURL ??
                                        "assets/images/profile/profile-image.png",
                                  ),
                            ),
                          );
                        } else {
                          // ❌ فشل تسجيل الدخول، إظهار رسالة خطأ
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("فشل تسجيل الدخول عبر Google"),
                            ),
                          );
                        }
                      }, // إضافة وظيفة تسجيل الدخول بـ Google
                      icon: const Icon(Icons.g_mobiledata, color: Colors.red),
                      label: Text(
                        'جوجل',
                        style: GoogleFonts.tajawal(fontSize: 14),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {}, // إضافة وظيفة تسجيل الدخول بـ Facebook
                      icon: const Icon(Icons.facebook, color: Colors.blue),
                      label: Text(
                        'فيسبوك',
                        style: GoogleFonts.tajawal(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ✅ زر الانتقال إلى صفحة التسجيل
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ليس لديك حساب؟',
                      style: GoogleFonts.tajawal(fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'إنشاء حساب جديد',
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFc6ab7c),
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
    );
  }
}
