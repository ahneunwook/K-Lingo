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

  /// 토큰 세팅
  Future<void> _setTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    
    _apiService.setAuthToken(accessToken);
    _apiService.setRefreshToken(refreshToken);
  }

  /// 토큰 삭제
  Future<void> _clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    _apiService.clearAuthToken();
  }

  /// ✅ 수정: 로그인 상태 확인
  Future<bool> isLoggedIn() async {
    try {
      print('🔍 AuthService: 로그인 상태 확인 시작');
      
      // 1. 저장된 토큰 불러오기
      final accessToken = await _storage.read(key: _accessTokenKey);
      final refreshToken = await _storage.read(key: _refreshTokenKey);

      // 토큰이 없으면 로그인 필요
      if (accessToken == null || accessToken.isEmpty) {
        print('❌ AuthService: 저장된 토큰 없음');
        return false;
      }

      print('✅ AuthService: 저장된 토큰 발견');
      print('   AccessToken: ${accessToken.substring(0, 20)}...');
      if (refreshToken != null) {
        print('   RefreshToken: ${refreshToken.substring(0, 20)}...');
      }

      // 2. ApiService에 토큰 장착 (✅ 이 순서가 중요!)
      _apiService.setAuthToken(accessToken);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        _apiService.setRefreshToken(refreshToken);
      }

      // 3. 간단한 API 호출로 토큰 유효성 검증
      print('🔍 AuthService: 토큰 유효성 검증 중...');
      await _apiService.get('/members/me/progress');
      
      print('✅ AuthService: 토큰 유효! (또는 갱신 성공)');
      return true;

    } catch (e) {
      print('❌ AuthService: 로그인 검증 실패 - $e');
      
      // 토큰 갱신도 실패했다면 로그아웃 처리
      await _clearTokens();
      return false;
    }
  }

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
}