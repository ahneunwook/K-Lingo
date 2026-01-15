// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _authToken;
  String? _refreshToken;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // ✅ 추가: 갱신 중복 방지
  bool _isRefreshing = false;

  void setAuthToken(String token) {
    _authToken = token;
    print('🔑 ApiService: AccessToken 설정됨 - ${token.substring(0, 20)}...');
  }

  void setRefreshToken(String token) {
    _refreshToken = token;
    print('🔑 ApiService: RefreshToken 설정됨 - ${token.substring(0, 20)}...');
  }

  void clearAuthToken() {
    _authToken = null;
    _refreshToken = null;
    print('🗑️ ApiService: 토큰 삭제됨');
  }

  Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  /// ✅ 수정완료: 토큰 갱신 (백엔드 스네이크 케이스 대응)
  Future<bool> _refreshAccessToken() async {
    // 1. 중복 갱신 방지
    if (_isRefreshing) {
      print('⏳ ApiService: 이미 토큰 갱신 중...');
      await Future.delayed(const Duration(milliseconds: 500));
      return _authToken != null;
    }

    // 2. 리프레시 토큰 유무 확인
    if (_refreshToken == null || _refreshToken!.isEmpty) {
      print('❌ ApiService: RefreshToken 없음 - 갱신 불가');
      return false;
    }

    _isRefreshing = true;
    print('🔄 ApiService: 토큰 갱신 시도 중...');

    try {
      final url = Uri.parse('${AppConfig.baseUrl}/auth/refresh');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': _refreshToken}),
      ).timeout(AppConfig.connectionTimeout);

      print('📡 ApiService: Refresh 응답 - ${response.statusCode}');

      if (response.statusCode == 200) {
        // 한글 깨짐 방지를 위한 decode
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final data = jsonResponse['data']; // ApiResponse의 data 필드
        
        final newAccessToken = data['access_token']; 
        final newRefreshToken = data['refresh_token'];
        
        // 디버깅 로그
        print('📦 파싱된 AccessToken: ${newAccessToken?.substring(0, 10)}...');

        // Null 체크 (방어 코드)
        if (newAccessToken == null) {
           print('❌ 키 값 불일치! data 내용을 확인하세요: $data');
           return false;
        }
        
        // 3. 메모리에 저장
        setAuthToken(newAccessToken);
        if (newRefreshToken != null) {
          setRefreshToken(newRefreshToken);
          // 4. 스토리지(휴대폰 저장소)에 저장
          await _storage.write(key: 'refresh_token', value: newRefreshToken);
        }
        await _storage.write(key: 'access_token', value: newAccessToken);

        print('✅ ApiService: 토큰 갱신 성공!');
        return true;
      }
      
      print('❌ ApiService: 토큰 갱신 실패 - ${response.statusCode}');
      return false;
      
    } catch (e) {
      print('❌ ApiService: 토큰 갱신 오류 - $e');
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      print('📤 GET: $endpoint');
      
      var response = await http.get(url, headers: _getHeaders())
          .timeout(AppConfig.connectionTimeout);

      // 401 발생 시 토큰 갱신 시도
      if (response.statusCode == 401 && !endpoint.contains('/auth/')) {
        print('⚠️ 401 에러 발생 - 토큰 갱신 시도');
        
        final refreshed = await _refreshAccessToken();
        
        if (refreshed) {
          print('✅ 토큰 갱신 성공 - 요청 재시도');
          response = await http.get(url, headers: _getHeaders())
              .timeout(AppConfig.connectionTimeout);
        } else {
          print('❌ 토큰 갱신 실패 - 로그인 필요');
          throw Exception('인증이 필요합니다. 다시 로그인해주세요.');
        }
      }

      return _handleResponse(response);
      
    } catch (e) {
      if (e.toString().contains('인증이 필요합니다')) rethrow;
      print('❌ GET Error ($endpoint): $e');
      throw Exception('네트워크 오류: $e');
    }
  }

  Future<dynamic> post(String endpoint, {dynamic data}) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      print('📤 POST: $endpoint');
      
      var response = await http.post(
        url,
        headers: _getHeaders(),
        body: data != null ? jsonEncode(data) : null,
      ).timeout(AppConfig.connectionTimeout);

      if (response.statusCode == 401 && !endpoint.contains('/auth/')) {
        print('⚠️ 401 에러 발생 - 토큰 갱신 시도');
        
        final refreshed = await _refreshAccessToken();
        
        if (refreshed) {
          print('✅ 토큰 갱신 성공 - 요청 재시도');
          response = await http.post(
            url,
            headers: _getHeaders(),
            body: data != null ? jsonEncode(data) : null,
          ).timeout(AppConfig.connectionTimeout);
        } else {
          throw Exception('인증이 필요합니다. 다시 로그인해주세요.');
        }
      }

      return _handleResponse(response);
      
    } catch (e) {
      if (e.toString().contains('인증이 필요합니다')) rethrow;
      print('❌ POST Error ($endpoint): $e');
      throw Exception('네트워크 오류: $e');
    }
  }

  Future<dynamic> put(String endpoint, {dynamic data}) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      print('📤 PUT: $endpoint');
      
      var response = await http.put(
        url,
        headers: _getHeaders(),
        body: data != null ? jsonEncode(data) : null,
      ).timeout(AppConfig.connectionTimeout);

      if (response.statusCode == 401 && !endpoint.contains('/auth/')) {
        final refreshed = await _refreshAccessToken();
        
        if (refreshed) {
          response = await http.put(
            url,
            headers: _getHeaders(),
            body: data != null ? jsonEncode(data) : null,
          ).timeout(AppConfig.connectionTimeout);
        } else {
          throw Exception('인증이 필요합니다. 다시 로그인해주세요.');
        }
      }

      return _handleResponse(response);
      
    } catch (e) {
      if (e.toString().contains('인증이 필요합니다')) rethrow;
      print('❌ PUT Error ($endpoint): $e');
      throw Exception('네트워크 오류: $e');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      print('📤 DELETE: $endpoint');
      
      var response = await http.delete(url, headers: _getHeaders())
          .timeout(AppConfig.connectionTimeout);

      if (response.statusCode == 401 && !endpoint.contains('/auth/')) {
        final refreshed = await _refreshAccessToken();
        
        if (refreshed) {
          response = await http.delete(url, headers: _getHeaders())
              .timeout(AppConfig.connectionTimeout);
        } else {
          throw Exception('인증이 필요합니다. 다시 로그인해주세요.');
        }
      }

      return _handleResponse(response);
      
    } catch (e) {
      if (e.toString().contains('인증이 필요합니다')) rethrow;
      print('❌ DELETE Error ($endpoint): $e');
      throw Exception('네트워크 오류: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    print('📥 Response: ${response.statusCode}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } catch (e) {
        return response.body;
      }
    } else if (response.statusCode == 401) {
      throw Exception('인증이 필요합니다. 다시 로그인해주세요.');
    } else if (response.statusCode == 403) {
      throw Exception('접근 권한이 없습니다.');
    } else if (response.statusCode == 404) {
      throw Exception('요청한 리소스를 찾을 수 없습니다.');
    } else {
      print('❌ 서버 오류: ${response.body}');
      throw Exception('서버 오류: ${response.statusCode}');
    }
  }
}