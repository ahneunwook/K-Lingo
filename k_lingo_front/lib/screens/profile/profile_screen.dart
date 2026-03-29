import 'package:flutter/material.dart';
import 'package:k_lingo_front/models/member/member_progress.dart'; // 모델 import
import 'package:k_lingo_front/services/member_service.dart';     // 서비스 import
// import 'package:k_lingo_front/screens/login/login_screen.dart';
// import 'package:k_lingo_front/services/auth_service.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // 서비스 인스턴스 생성
  final MemberService _memberService = MemberService();
  // final AuthService _authService = AuthService(); // 로그아웃용

  // 데이터를 담을 Future 변수
  Future<MemberProfile>? _profileFuture;

  // 테마 컬러
  final Color _primaryColor = const Color(0xFFA855F7);
  
  // 스위치 상태
  bool _isNotificationOn = true;
  bool _isSoundOn = true;

  @override
  void initState() {
    super.initState();
    // 화면이 켜질 때 내 프로필 정보를 요청합니다.
    _profileFuture = _memberService.getMyProfile();
  }

  // 새로고침 기능 (화면을 당겼을 때)
  Future<void> _refreshProfile() async {
    setState(() {
      _profileFuture = _memberService.getMyProfile();
    });
  }

//   void _handleLogout() async { ... } (기존 로그아웃 로직 유지)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        // FutureBuilder로 감싸서 데이터 상태(로딩/성공/실패)에 따라 화면을 그립니다.
        child: FutureBuilder<MemberProfile>(
          future: _profileFuture,
          builder: (context, snapshot) {
            // 1. 로딩 중일 때
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            // 2. 에러 났을 때
            else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("프로필을 불러오지 못했습니다."),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _refreshProfile, 
                      child: const Text("다시 시도")
                    ),
                  ],
                ),
              );
            }
            // 3. 데이터가 없을 때
            else if (!snapshot.hasData) {
              return const Center(child: Text("정보가 없습니다."));
            }

            // 4. 성공! 데이터 가져오기
            final profile = snapshot.data!;

            return RefreshIndicator(
              onRefresh: _refreshProfile,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(), // 당겨서 새로고침 가능
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // 헤더에 데이터 전달
                    _buildProfileHeader(profile),
                    
                    const SizedBox(height: 30),

                    // 통계 카드에 데이터 전달
                    _buildStatsCard(profile),

                    const SizedBox(height: 30),

                    // --- 아래 설정 메뉴는 고정값이므로 그대로 유지 ---
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
                      // onTap: _showLogoutDialog, 
                    ),
                    
                    const SizedBox(height: 40),
                    
                    Text(
                      "Version 1.0.0",
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- 위젯 빌더 메서드 (데이터 바인딩 적용) ---

  Widget _buildProfileHeader(MemberProfile profile) {
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
                image: DecorationImage(
                  // 프로필 이미지가 없으면 기본 이미지(또는 플레이스홀더) 사용
                  image: (profile.profileImageUrl.isNotEmpty)
                      ? NetworkImage(profile.profileImageUrl)
                      : const NetworkImage('https://i.pravatar.cc/300'),
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
        Text(
          profile.nickname, // 닉네임 바인딩
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        Text(
          "${profile.role} 🔥", // 칭호 바인딩
          style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildStatsCard(MemberProfile profile) {
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
          // 서버 DTO에 맞게 데이터 연결
          _buildStatItem(Icons.timer_outlined, profile.totalStudyTime, "Study Time", Colors.orange),
          Container(width: 1, height: 40, color: Colors.grey[200]), 
          
          _buildStatItem(Icons.quiz_outlined, "${profile.totalQuizCount}", "Quizzes", _primaryColor),
          Container(width: 1, height: 40, color: Colors.grey[200]), 
          
          _buildStatItem(Icons.school_outlined, profile.topikLevel, "Level", Colors.blueAccent),
        ],
      ),
    );
  }

  // (아래 헬퍼 메서드들은 변경 없음)
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
          style: TextStyle(color: Colors.grey[800], fontSize: 16, fontWeight: FontWeight.bold),
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
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: textColor ?? Colors.black87),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}