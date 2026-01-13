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
      // 1. 저장된 토큰 불러오기
      final accessToken = await _storage.read(key: _accessTokenKey);
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      
      // 토큰이 아예 없으면 로그인 필요
      if (accessToken == null || accessToken.isEmpty) {
        return false;
      }

      // 2. ApiService에 토큰 장착 (이게 있어야 요청을 보냄)
      _apiService.setAuthToken(accessToken);
      if (refreshToken != null) {
        _apiService.setRefreshToken(refreshToken);
      }

      // 3. 테스트 API 호출
      // ApiService가 내부적으로 (401 발생 -> 토큰 갱신 -> 재요청) 과정을 처리합니다.
      await _apiService.get('/words/categories');
      
      // 에러 없이 여기까지 왔다면 로그인(또는 갱신) 성공!
      return true;

    } catch (e) {
      print('❌ 로그인 검증 실패: $e');
      // ApiService가 갱신까지 시도했으나 실패한 경우이므로 로그아웃 처리
      await _clearTokens();
      return false;
    }
  }

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
}