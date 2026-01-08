// lib/services/auth_service.dart

import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import '../models/auth/auth_token_response.dart';
import 'dart:io';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: Platform.isIOS
        ? '98735289564-nh4unvi972tbuculvhea2ah2muikg33o.apps.googleusercontent.com'
        : null,
    serverClientId: '98735289564-0aanklfi4f1ql90ghsvvra7jfj3i6pvd.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ApiService _apiService = ApiService();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  /// Google 로그인
  Future<AuthTokenResponse> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google 로그인이 취소되었습니다.');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Google idToken을 가져올 수 없습니다.');
      }

      final response = await _apiService.post(
        '/auth/login/google',
        data: {'idToken': idToken},
      );

      final tokenResponse = AuthTokenResponse.fromJson(response['data']);
      
      // ✅ 한 번에 처리
      await _setTokens(tokenResponse.accessToken, tokenResponse.refreshToken);

      return tokenResponse;
    } catch (e) {
      print('❌ Google 로그인 실패: $e');
      rethrow;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _clearTokens();
  }

  /// ✅ 토큰 세팅 (SecureStorage + ApiService 메모리 동시 처리)
  Future<void> _setTokens(String accessToken, String refreshToken) async {
    // SecureStorage에 저장
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    
    // ApiService 메모리에 저장
    _apiService.setAuthToken(accessToken);
    _apiService.setRefreshToken(refreshToken);
  }

  /// 토큰 삭제
  Future<void> _clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    _apiService.clearAuthToken();
  }

  /// 로그인 상태 확인 (앱 시작 시)
  Future<bool> isLoggedIn() async {
    try {
      final accessToken = await _storage.read(key: _accessTokenKey);
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      
      if (accessToken == null || accessToken.isEmpty) {
        return false;
      }

      // ApiService 메모리에 토큰 복원
      _apiService.setAuthToken(accessToken);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        _apiService.setRefreshToken(refreshToken);
      }

      try {
        // 간단한 API 호출로 토큰 검증
        await _apiService.get('/words/categories');
        return true;
      } catch (e) {
        // 인증 실패 시 토큰 삭제
        if (e.toString().contains('인증이 필요합니다')) {
          await _clearTokens();
        }
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// 현재 Google 계정 정보
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
}