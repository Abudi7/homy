import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homy/views/screens/home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>(); // ✅ مفتاح التحقق من صحة الإدخالات
  final FirebaseAuth _auth = FirebaseAuth.instance; // ✅ Firebase Authentication
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // ✅ Firestore لتخزين بيانات المستخدم

  String? firstName, lastName, email, password, confirmPassword, birthday, address, gender;
  bool isLoading = false; // ✅ متغير لتحديد حالة التحميل

  // ✅ دالة تسجيل المستخدم وحفظ بياناته في Firestore
  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return; // ✅ التحقق من صحة الإدخالات
    _formKey.currentState!.save(); // ✅ حفظ القيم بعد التحقق

    // ✅ التحقق من تطابق كلمتي المرور
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كلمتا المرور غير متطابقتين', textAlign: TextAlign.center)),
      );
      return;
    }

    setState(() => isLoading = true); // ✅ تفعيل مؤشر التحميل

    try {
      // ✅ إنشاء المستخدم في Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email!,
        password: password!,
      );

      // ✅ توليد معرف (ID) تلقائي للمستخدم في Firestore
      String userId = userCredential.user!.uid;

      // ✅ تعيين صورة الملف الشخصي الافتراضية
      String profileImage = "assets/images/profile/profile-image.png";

      // ✅ حفظ بيانات المستخدم في Firestore
      await _firestore.collection("users").doc(userId).set({
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "birthday": birthday,
        "address": address,
        "gender": gender,
        "profileImage": profileImage, // ✅ صورة الملف الشخصي الافتراضية
        "createdAt": FieldValue.serverTimestamp(), // ✅ تاريخ إنشاء الحساب
      });

      if (!mounted) return;

      // ✅ عرض رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم التسجيل بنجاح!', textAlign: TextAlign.center)),
      );

      // ✅ الانتقال إلى الصفحة الرئيسية بعد نجاح التسجيل
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(userName: firstName!)),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = "حدث خطأ أثناء إنشاء الحساب";

      // ✅ معالجة الأخطاء المحتملة
      if (e.code == 'email-already-in-use') {
        errorMessage = "هذا البريد الإلكتروني مسجل بالفعل";
      } else if (e.code == 'invalid-email') {
        errorMessage = "تنسيق البريد الإلكتروني غير صالح";
      } else if (e.code == 'weak-password') {
        errorMessage = "كلمة المرور ضعيفة جدًا، اختر كلمة أقوى";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage, textAlign: TextAlign.center)),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false); // ✅ إيقاف مؤشر التحميل
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // ✅ دعم اللغة العربية
      child: Scaffold(
        appBar: AppBar(
          title: Text('إنشاء حساب جديد', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset('assets/images/logo.png', height: 120),
                const SizedBox(height: 10),

                // ✅ الاسم الأول
                TextFormField(
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    labelText: 'الاسم الأول',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'يرجى إدخال الاسم الأول' : null,
                  onSaved: (value) => firstName = value,
                ),
                const SizedBox(height: 10),

                // ✅ اللقب
                TextFormField(
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    labelText: 'اللقب',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.badge),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'يرجى إدخال اللقب' : null,
                  onSaved: (value) => lastName = value,
                ),
                const SizedBox(height: 10),

                // ✅ البريد الإلكتروني
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'يرجى إدخال البريد الإلكتروني' : null,
                  onSaved: (value) => email = value,
                ),
                const SizedBox(height: 10),

                // ✅ كلمة المرور
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  onSaved: (value) => password = value,
                ),
                const SizedBox(height: 10),

                // ✅ تأكيد كلمة المرور
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'تأكيد كلمة المرور',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  onSaved: (value) => confirmPassword = value,
                ),
                const SizedBox(height: 10),

                // ✅ تاريخ الميلاد
                TextFormField(
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    labelText: 'تاريخ الميلاد (YYYY-MM-DD)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  onSaved: (value) => birthday = value,
                ),
                const SizedBox(height: 10),

                // ✅ العنوان
                TextFormField(
                  keyboardType: TextInputType.streetAddress,
                  decoration: InputDecoration(
                    labelText: 'العنوان',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.home),
                  ),
                  onSaved: (value) => address = value,
                ),
                const SizedBox(height: 10),

                // ✅ الجنس
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'الجنس',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  items: [
                    DropdownMenuItem(value: 'ذكر', child: Text('ذكر')),
                    DropdownMenuItem(value: 'أنثى', child: Text('أنثى')),
                  ],
                  onChanged: (value) => gender = value,
                ),
                const SizedBox(height: 10),

                // ✅ زر التسجيل
                ElevatedButton(
                  onPressed: isLoading ? null : registerUser,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFc6ab7c)),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('إنشاء الحساب', style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                ),
                const SizedBox(height: 10),

                // ✅ زر تسجيل الدخول إذا كان لديه حساب
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('هل لديك حساب؟', style: GoogleFonts.tajawal(fontSize: 14)),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'تسجيل الدخول',
                        style: GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFc6ab7c)),
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