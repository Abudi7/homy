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
        firstName = userData['firstName'];
        lastName = userData['lastName'];
        email = userData['email'];
        address = userData['address'];
        gender = userData['gender'];
        profileImageUrl = userData['profileImage'];

        // ✅ تحويل تاريخ الميلاد المخزن كنص إلى كائن `DateTime`
        birthday = userData['birthday'] != null
            ? DateTime.parse(userData['birthday'])
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
        "birthday": birthday,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث البيانات بنجاح!')),
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
      appBar: AppBar(title: const Text("الملف الشخصي")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // ✅ صورة المستخدم مع إمكانية التغيير
                GestureDetector(
                  onTap: _updateProfileImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: profileImageUrl != null
                        ? NetworkImage(profileImageUrl!)
                        : null,
                    child: profileImageUrl == null
                        ? const Icon(Icons.camera_alt)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),

                // ✅ الاسم الأول
                TextFormField(
                  initialValue: firstName,
                  decoration: const InputDecoration(labelText: "الاسم الأول"),
                  onChanged: (value) => firstName = value,
                ),
                const SizedBox(height: 10),

                // ✅ اللقب
                TextFormField(
                  initialValue: lastName,
                  decoration: const InputDecoration(labelText: "اللقب"),
                  onChanged: (value) => lastName = value,
                ),
                const SizedBox(height: 10),

                // ✅ البريد الإلكتروني (غير قابل للتعديل)
                TextFormField(
                  initialValue: email,
                  decoration: const InputDecoration(labelText: "البريد الإلكتروني"),
                  enabled: false,
                ),
                const SizedBox(height: 10),

                // ✅ العنوان
                TextFormField(
                  initialValue: address,
                  decoration: const InputDecoration(labelText: "العنوان"),
                  onChanged: (value) => address = value,
                ),
                const SizedBox(height: 10),

                // ✅ الجنس
                DropdownButtonFormField<String>(
                  value: gender,
                  decoration: const InputDecoration(labelText: "الجنس"),
                  items: const [
                    DropdownMenuItem(value: 'ذكر', child: Text('ذكر')),
                    DropdownMenuItem(value: 'أنثى', child: Text('أنثى')),
                  ],
                  onChanged: (value) => setState(() => gender = value),
                ),
                const SizedBox(height: 10),

                // ✅ تاريخ الميلاد باستخدام التقويم
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'تاريخ الميلاد',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.date_range),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                  controller: TextEditingController(
                    text: birthday != null
                        ? "${birthday!.year}-${birthday!.month}-${birthday!.day}"
                        : "",
                  ),
                ),
                const SizedBox(height: 20),

                // ✅ زر التحديث
                ElevatedButton(
                  onPressed: _updateUserInfo,
                  child: const Text("تحديث البيانات"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
