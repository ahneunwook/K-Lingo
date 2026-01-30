import 'package:flutter/material.dart';
import 'package:k_lingo_front/screens/home/home_screen.dart'; // 홈 화면 import
import 'package:k_lingo_front/widgets/common_bottom_bar.dart'; // 하단 바 import
import 'package:k_lingo_front/screens/profile/profile_screen.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // 현재 탭 번호

  // 탭별 화면 리스트 (알맹이들)
  final List<Widget> _screens = [
    const HomeScreen(),          // 0: Home
    const Center(child: Text("Review Screen")), // 1: Review
    const Center(child: Text("Search Screen")), // 2: Search
    const Center(child: Text("Stats Screen")),  // 3: Stats
    const ProfileScreen(),
  ];

  // 탭 클릭 시 실행
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✨ 핵심: 탭 번호에 따라 내용물(body)만 싹 바뀝니다.
      body: _screens[_selectedIndex],
      
      // ✨ 하단 바는 고정!
      bottomNavigationBar: CommonBottomBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}