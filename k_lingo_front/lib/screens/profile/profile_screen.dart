import 'package:flutter/material.dart';
import 'package:k_lingo_front/screens/login/login_screen.dart'; // 로그인 화면 import
import 'package:k_lingo_front/services/auth_service.dart'; // 로그아웃용

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  
  // 테마 컬러
  final Color _primaryColor = const Color(0xFFA855F7);
  
  // 스위치 상태 (예시)
  bool _isNotificationOn = true;
  bool _isSoundOn = true;

//   // 로그아웃 처리
//   void _handleLogout() async {
//     // 1. 토큰 삭제
//     await _authService.logout();
    
//     // 2. 로그인 화면으로 이동 (뒤로가기 방지)
//     if (mounted) {
//       Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(builder: (context) => const LoginScreen()),
//         (route) => false,
//       );
//     }
//   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // 1. 프로필 헤더 (이미지 + 이름)
              _buildProfileHeader(),
              
              const SizedBox(height: 30),

              // 2. 학습 통계 요약 (Streak, XP, Rank)
              _buildStatsCard(),

              const SizedBox(height: 30),

              // 3. 설정 메뉴 리스트
              _buildSectionTitle("General Settings"),
              _buildSettingsTile(
                icon: Icons.notifications_outlined,
                title: "Notifications",
                trailing: Switch(
                  value: _isNotificationOn,
                  activeColor: _primaryColor,
                  onChanged: (value) => setState(() => _isNotificationOn = value),
                ),
              ),
              _buildSettingsTile(
                icon: Icons.volume_up_outlined,
                title: "Sound Effects",
                trailing: Switch(
                  value: _isSoundOn,
                  activeColor: _primaryColor,
                  onChanged: (value) => setState(() => _isSoundOn = value),
                ),
              ),
              _buildSettingsTile(
                icon: Icons.language,
                title: "Language",
                trailing: const Text("English", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                onTap: () {},
              ),

              const SizedBox(height: 20),

              _buildSectionTitle("Account"),
              _buildSettingsTile(
                icon: Icons.help_outline_rounded,
                title: "Help & Support",
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: Icons.logout_rounded,
                title: "Logout",
                textColor: Colors.redAccent,
                iconColor: Colors.redAccent,
                // onTap: _showLogoutDialog, // 다이얼로그 띄우기
              ),
              
              const SizedBox(height: 40),
              
              // 앱 버전
              Text(
                "Version 1.0.0",
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 위젯 빌더 메서드 ---

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _primaryColor.withOpacity(0.2), width: 4),
                image: const DecorationImage(
                  // 실제 프로필 이미지가 없으면 플레이스홀더 사용
                  image: NetworkImage('https://i.pravatar.cc/300'), 
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          "안은욱", // 실제 사용자 이름 변수
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        Text(
          "Lv.5 Passionate Learner 🔥",
          style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(Icons.local_fire_department_rounded, "12", "Day Streak", Colors.orange),
          Container(width: 1, height: 40, color: Colors.grey[200]), // 구분선
          _buildStatItem(Icons.bolt_rounded, "1,240", "Total XP", Colors.yellow[700]!),
          Container(width: 1, height: 40, color: Colors.grey[200]), // 구분선
          _buildStatItem(Icons.emoji_events_rounded, "Gold", "League", _primaryColor),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 4),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (iconColor ?? _primaryColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor ?? _primaryColor, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: textColor ?? Colors.black87,
          ),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

//   void _showLogoutDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Logout"),
//         content: const Text("Are you sure you want to log out?"),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _handleLogout();
//             },
//             child: const Text("Logout", style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
}