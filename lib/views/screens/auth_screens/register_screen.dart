import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  String? firstName, lastName, email, password, age, address, gender;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
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
                const SizedBox(height: 10), // تقليل المسافة

                TextFormField(
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'الاسم الأول',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'يرجى إدخال الاسم الأول' : null,
                  onSaved: (value) => firstName = value,
                ),
                const SizedBox(height: 10),

                TextFormField(
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'اللقب',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.badge),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'يرجى إدخال اللقب' : null,
                  onSaved: (value) => lastName = value,
                ),
                const SizedBox(height: 10),

                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'يرجى إدخال البريد الإلكتروني';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'يرجى إدخال بريد إلكتروني صالح';
                    return null;
                  },
                  onSaved: (value) => email = value,
                ),
                const SizedBox(height: 10),

                TextFormField(
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'يرجى إدخال كلمة المرور';
                    if (value.length < 6) return 'يجب أن تكون كلمة المرور مكونة من 6 أحرف على الأقل';
                    return null;
                  },
                  onSaved: (value) => password = value,
                ),
                const SizedBox(height: 10),

                TextFormField(
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'العمر',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.cake),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'يرجى إدخال العمر';
                    if (int.tryParse(value) == null || int.parse(value) < 10) return 'يجب أن يكون العمر أكبر من 10';
                    return null;
                  },
                  onSaved: (value) => age = value,
                ),
                const SizedBox(height: 10),

                TextFormField(
                  keyboardType: TextInputType.streetAddress,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'العنوان',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.home),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'يرجى إدخال العنوان' : null,
                  onSaved: (value) => address = value,
                ),
                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'الجنس',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  items: ['ذكر', 'أنثى'].map((String gender) {
                    return DropdownMenuItem<String>(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  validator: (value) => value == null ? 'يرجى اختيار الجنس' : null,
                  onChanged: (value) => gender = value,
                ),
                const SizedBox(height: 15),

                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم إنشاء الحساب بنجاح!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFc6ab7c),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'إنشاء الحساب',
                    style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 10),

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
