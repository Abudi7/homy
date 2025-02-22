//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homy/views/screens/auth_screens/login_screen.dart';
import 'package:homy/views/screens/profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String profileImage; // ✅ إضافة الصورة الشخصية

  const HomeScreen({super.key, required this.userName, required this.profileImage});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // ✅ لتحديد القسم النشط في `BottomNavigationBar`

  // ✅ تحديث `BottomNavigationBar` عند تغيير القسم
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // ✅ تسجيل الخروج
  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الصفحة الرئيسية"),
        centerTitle: true,
        backgroundColor: const Color(0xFFc6ab7c),
        actions: [
          // ✅ قائمة منسدلة تحتوي على البروفايل وتسجيل الخروج
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              icon: CircleAvatar(
                backgroundImage: NetworkImage(widget.profileImage),
                radius: 18,
              ),
              onChanged: (String? value) {
                if (value == "profile") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                } else if (value == "logout") {
                  _logout();
                }
              },
              items: [
                DropdownMenuItem(
                  value: "profile",
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: Colors.black),
                      const SizedBox(width: 8),
                      Text("الملف الشخصي"),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: "logout",
                  child: Row(
                    children: [
                      const Icon(Icons.logout, color: Colors.red),
                      const SizedBox(width: 8),
                      Text("تسجيل الخروج"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ✅ شريط البحث
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "ابحث عن عقار...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text("عرض قائمة العقارات هنا", style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),

      // ✅ شريط التنقل السفلي
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "الرئيسية"),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: "العقارات"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "الإعدادات"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.brown,
        onTap: _onItemTapped,
      ),
    );
  }
}
