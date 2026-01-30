import 'package:flutter/material.dart';
import 'common_bottom_bar.dart';

class MainLayout extends StatelessWidget {
  final String title;       // 화면 제목
  final Widget body;        // 화면 내용
  final int bottomTabIndex; // 하단 바 몇 번째 불 켤지

  const MainLayout({
    super.key,
    required this.title,
    required this.body,
    this.bottomTabIndex = 0, // 기본값 0
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      
      // 1. 공통 앱바
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      // 2. 내용물
      body: body,

      // 3. 공통 하단 바
      bottomNavigationBar: CommonBottomBar(
        currentIndex: bottomTabIndex,
        
        // 👇 [에러 해결] onTap을 여기서 정의해줘야 합니다!
        onTap: (index) {
          // 서브 화면에서 탭을 누르면, 무조건 메인 화면(첫 화면)으로 돌아가게 설정
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
    );
  }
}