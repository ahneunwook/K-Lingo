import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import '../models/auth/auth_token_response.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // iOS 클라이언트 ID (같은 프로젝트 98735289564)
    clientId: '98735289564-nh4unvi972tbuculvhea2ah2muikg33o.apps.googleusercontent.com',
    // 웹 클라이언트 ID (백엔드 검증용 - idToken의 audience가 됨)
    serverClientId: '98735289564-0aanklfi4f1ql90ghsvvra7jfj3i6pvd.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ApiService _apiService = ApiService();

  // 저장소 키
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  /// Google 로그인
  Future<AuthTokenResponse> signInWithGoogle() async {
    try {
      // 1. Google 로그인 다이얼로그 표시
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google 로그인이 취소되었습니다.');
      }

      // 2. idToken 가져오기
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Google idToken을 가져올 수 없습니다.');
      }

      // 3. 백엔드에 idToken 전송 → JWT 받기
      final response = await _apiService.post(
        '/auth/login/google',
        data: {'idToken': idToken},
      );

      // 4. 응답 파싱
      final tokenResponse = AuthTokenResponse.fromJson(response['data']);

      // 5. 토큰 저장
      await _saveTokens(tokenResponse);

      // 6. ApiService에 토큰 설정
      _apiService.setAuthToken(tokenResponse.accessToken);

      return tokenResponse;
    } catch (e) {
      rethrow;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _clearTokens();
    _apiService.clearAuthToken();
  }

  /// 토큰 저장
  Future<void> _saveTokens(AuthTokenResponse tokens) async {
    await _storage.write(key: _accessTokenKey, value: tokens.accessToken);
    await _storage.write(key: _refreshTokenKey, value: tokens.refreshToken);
  }

  /// 토큰 삭제
  Future<void> _clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  /// 저장된 토큰 불러오기
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// 로그인 상태 확인 (앱 시작 시)
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    if (token != null) {
      _apiService.setAuthToken(token);
      return true;
    }
    return false;
  }

  /// 현재 Google 계정 정보
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
}
