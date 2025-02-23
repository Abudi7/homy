import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // ✅ استيراد خط Tajawal
import 'package:homy/views/screens/auth_screens/login_screen.dart';
import 'package:homy/views/screens/profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String profileImage;

  const HomeScreen({super.key, required this.userName, required this.profileImage});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfileImage();
  }

  // ✅ تحميل صورة المستخدم من Firestore
  Future<void> _loadUserProfileImage() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        profileImageUrl = userData['profileImage'];
      });
    }
  }

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
      backgroundColor: Colors.grey[100],

      // ✅ AppBar بتصميم عصري
      appBar: AppBar(
        title: Text(
          "الصفحة الرئيسية",
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFc6ab7c),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: PopupMenuButton<String>(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              icon: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                backgroundImage: profileImageUrl != null
                    ? NetworkImage(profileImageUrl!)
                    : const AssetImage("assets/images/profile/profile-image.png") as ImageProvider,
                child: profileImageUrl == null
                    ? const Icon(Icons.person, color: Colors.white, size: 30)
                    : null,
              ),
              onSelected: (String value) {
                if (value == "profile") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                } else if (value == "logout") {
                  _logout();
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: "profile",
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Colors.black),
                    title: Text("الملف الشخصي", style: GoogleFonts.tajawal(fontSize: 16)),
                  ),
                ),
                PopupMenuItem(
                  value: "logout",
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: Text("تسجيل الخروج", style: GoogleFonts.tajawal(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ✅ قسم البحث
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "ابحث عن عقار...",
                hintStyle: GoogleFonts.tajawal(fontSize: 16),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                suffixIcon: const Icon(Icons.filter_list, color: Colors.grey),
              ),
            ),
          ),

          // ✅ لا يوجد عقارات مضافة بعد
          Expanded(
            child: Center(
              child: Text(
                "لا يوجد عقارات مضافة بعد",
                style: GoogleFonts.tajawal(fontSize: 18, color: Colors.grey[600]),
              ),
            ),
          ),
        ],
      ),

      // ✅ شريط التنقل السفلي
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: "الرئيسية",
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.business),
            label: "العقارات",
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: "الإعدادات",
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFc6ab7c),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 10,
        selectedLabelStyle: GoogleFonts.tajawal(fontSize: 14),
        unselectedLabelStyle: GoogleFonts.tajawal(fontSize: 12),
        onTap: _onItemTapped,
      ),
    );
  }
}
