import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    
    try {
      await _authService.signInWithGoogle();
      
      if (!mounted) return;
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Google 로그인에 실패했습니다: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAppleLogin() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Apple 로그인 구현
      _showErrorSnackBar('Apple 로그인은 준비 중입니다');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              
              // 로고 & 타이틀
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'K',
                    style: GoogleFonts.poppins(
                      fontSize: 45,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.white,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'KoreanMate',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                '한국어 학습을 시작해보세요',
                style: GoogleFonts.notoSansKr(
                  fontSize: 15,
                  color: AppTheme.textSecondary,
                ),
              ),
              
              const Spacer(flex: 2),
              
              // 소셜 로그인 버튼들
              _SocialLoginButton(
                onPressed: _isLoading ? null : _handleAppleLogin,
                icon: Icons.apple,
                label: 'Apple로 계속하기',
                backgroundColor: Colors.black,
                textColor: Colors.white,
              ),
              
              const SizedBox(height: 14),
              
              _SocialLoginButton(
                onPressed: _isLoading ? null : _handleGoogleLogin,
                customIcon: SvgPicture.asset(
                  'assets/images/google_logo.svg',
                  width: 20,
                  height: 20,
                ),
                label: 'Google로 계속하기',
                backgroundColor: Colors.white,
                textColor: AppTheme.textPrimary,
                borderColor: Colors.grey.shade300,
              ),
              
              const Spacer(flex: 1),
              
              // 로딩 인디케이터 (자리 항상 확보)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: SizedBox(
                  height: 30,
                  child: _isLoading
                      ? const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryColor,
                            ),
                            strokeWidth: 2.5,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              
              // 하단 약관 안내
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Text(
                  '로그인 시 이용약관 및 개인정보처리방침에\n동의하는 것으로 간주됩니다.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansKr(
                    fontSize: 12,
                    color: AppTheme.textSecondary.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData? icon;
  final Widget? customIcon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  const _SocialLoginButton({
    required this.onPressed,
    this.icon,
    this.customIcon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: borderColor != null
                ? BorderSide(color: borderColor!)
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(icon, size: 22)
            else if (customIcon != null)
              customIcon!,
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.notoSansKr(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
