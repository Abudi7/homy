import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homy/views/screens/auth_screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  // مفاتيح النموذج (Form) للتحقق من صحة الإدخال
  final _formKey = GlobalKey<FormState>();

  // المتغيرات لتخزين بيانات البريد الإلكتروني وكلمة المرور
  String? email;
  String? password;

  @override
  Widget build(BuildContext context) {
    return Directionality( // إضافة اتجاه RTL لدعم اللغة العربية
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey, // تعيين مفتاح النموذج للتحقق من الإدخال
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 50),
                Image.asset(
                  'assets/images/logo.png',
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
                // حقل إدخال البريد الإلكتروني مع التحقق من صحة الإدخال
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال البريد الإلكتروني';
                    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'يرجى إدخال بريد إلكتروني صالح';
                    }
                    return null;
                  },
                  onSaved: (value) => email = value,
                ),
                const SizedBox(height: 16),
                // حقل إدخال كلمة المرور مع التحقق من صحة الإدخال
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال كلمة المرور';
                    } else if (value.length < 6) {
                      return 'يجب أن تكون كلمة المرور مكونة من 6 أحرف على الأقل';
                    }
                    return null;
                  },
                  onSaved: (value) => password = value,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // تحقق من صحة النموذج
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // تنفيذ إجراء تسجيل الدخول هنا
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم تسجيل الدخول بنجاح')),
                      );
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(const Color(0xFFc6ab7c)),
                  ),
                  child: Text(
                    'تسجيل الدخول',
                    style: GoogleFonts.tajawal(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 10, 10, 10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // أزرار تسجيل الدخول باستخدام جوجل وفيسبوك
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.g_mobiledata, color: Colors.red),
                      label: Text('جوجل', style: GoogleFonts.tajawal(fontSize: 14)),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.facebook, color: Colors.blue),
                      label: Text('فيسبوك', style: GoogleFonts.tajawal(fontSize: 14)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // زر الانتقال إلى صفحة التسجيل
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('ليس لديك حساب؟', style: GoogleFonts.tajawal(fontSize: 14)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: Text(
                        'إنشاء حساب جديد',
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFc6ab7c),
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
