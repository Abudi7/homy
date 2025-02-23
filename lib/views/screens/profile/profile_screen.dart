import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  String? firstName, lastName, email, address, gender;
  DateTime? birthday;
  File? image;
  String? profileImageUrl;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ✅ تحميل بيانات المستخدم من Firestore
  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        firstName = userData['firstName'] ?? "مستخدم";
        lastName = userData['lastName'] ?? "";
        email = userData['email'] ?? "";
        address = userData['address'] ?? "لم يتم تحديد العنوان";
        gender = userData['gender'] ?? "غير محدد";
        profileImageUrl = userData['profileImage'] ?? "assets/images/default-profile.png";
        birthday = userData['birthday'] != null
            ? DateTime.tryParse(userData['birthday'])
            : null;
      });
    }
  }

  // ✅ تحديث صورة البروفايل في Firebase Storage
  Future<void> _updateProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Reference storageRef =
          FirebaseStorage.instance.ref().child("profile_images/${user.uid}.jpg");
      await storageRef.putFile(imageFile);
      String newImageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        "profileImage": newImageUrl,
      });

      setState(() {
        profileImageUrl = newImageUrl;
      });
    }
  }

  // ✅ تحديث معلومات المستخدم
  Future<void> _updateUserInfo() async {
    if (!_formKey.currentState!.validate()) return;

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        "firstName": firstName,
        "lastName": lastName,
        "address": address,
        "gender": gender,
        "birthday": birthday?.toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم تحديث البيانات بنجاح!'),
            backgroundColor: const Color(0xFFc6ab7c),
          ),
        );
      }
    }
  }

  // ✅ اختيار تاريخ الميلاد باستخدام التقويم
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: birthday ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != birthday) {
      setState(() {
        birthday = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "الملف الشخصي",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFc6ab7c),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ✅ صورة البروفايل مع إمكانية التحديث
            GestureDetector(
              onTap: _updateProfileImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
                        ? NetworkImage(profileImageUrl!)
                        : const AssetImage("assets/images/default-profile.png") as ImageProvider,
                    child: profileImageUrl == null || profileImageUrl!.isEmpty
                        ? const Icon(Icons.person, size: 50, color: Colors.white)
                        : null,
                  ),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.camera_alt, color: Color(0xFFc6ab7c), size: 22),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ✅ بيانات المستخدم داخل بطاقة
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTextField("الاسم الأول", firstName, (val) => firstName = val),
                    _buildTextField("اللقب", lastName, (val) => lastName = val),
                    _buildTextField("البريد الإلكتروني", email, null, enabled: false),
                    _buildTextField("العنوان", address, (val) => address = val),
                    _buildDropdownField("الجنس", gender, ['ذكر', 'أنثى'], (val) => setState(() => gender = val)),
                    _buildDatePicker("تاريخ الميلاد", birthday, () => _selectDate(context)),
                    const SizedBox(height: 20),

                    // ✅ زر التحديث
                    ElevatedButton.icon(
                      onPressed: _updateUserInfo,
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text("تحديث البيانات", style: TextStyle(fontSize: 16, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFc6ab7c),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ دالة لإنشاء الحقول النصية
  Widget _buildTextField(String label, String? value, Function(String)? onChanged, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: value,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        onChanged: onChanged,
      ),
    );
  }

  // ✅ دالة لإنشاء قائمة اختيار (Dropdown)
  Widget _buildDropdownField(String label, String? value, List<String> items, Function(String?)? onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  // ✅ دالة لإنشاء حقل اختيار التاريخ
  Widget _buildDatePicker(String label, DateTime? date, VoidCallback onTap) {
    return _buildTextField(label, date != null ? "${date.year}-${date.month}-${date.day}" : "", (_) {}, enabled: false);
  }
}
