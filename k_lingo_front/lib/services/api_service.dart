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

  void setAuthToken(String token) {
    _authToken = token;
  }

  void setRefreshToken(String token) {
    _refreshToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
    _refreshToken = null;
  }

  Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  /// ✅ 토큰 갱신 (메모리 + SecureStorage 동시 저장)
  Future<bool> _refreshAccessToken() async {
    if (_refreshToken == null) return false;

    try {
      final url = Uri.parse('${AppConfig.baseUrl}/auth/refresh');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': _refreshToken}),
      ).timeout(AppConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final newAccessToken = data['data']['accessToken'];
        final newRefreshToken = data['data']['refreshToken'];
        
        // 메모리에 저장
        setAuthToken(newAccessToken);
        setRefreshToken(newRefreshToken);
        
        // ✅ SecureStorage에도 저장 (앱 재시작 시에도 유지)
        await _storage.write(key: 'access_token', value: newAccessToken);
        await _storage.write(key: 'refresh_token', value: newRefreshToken);
        
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      var response = await http.get(url, headers: _getHeaders())
          .timeout(AppConfig.connectionTimeout);

      if (response.statusCode == 401 && !endpoint.contains('/auth/')) {
        final refreshed = await _refreshAccessToken();
        
        if (refreshed) {
          response = await http.get(url, headers: _getHeaders())
              .timeout(AppConfig.connectionTimeout);
        } else {
          throw Exception('인증이 필요합니다. 다시 로그인해주세요.');
        }
      }

      return _handleResponse(response);
    } catch (e) {
      if (e.toString().contains('인증이 필요합니다')) rethrow;
      throw Exception('네트워크 오류: $e');
    }
  }

  Future<dynamic> post(String endpoint, {dynamic data}) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      var response = await http.post(
        url,
        headers: _getHeaders(),
        body: data != null ? jsonEncode(data) : null,
      ).timeout(AppConfig.connectionTimeout);

      if (response.statusCode == 401 && !endpoint.contains('/auth/')) {
        final refreshed = await _refreshAccessToken();
        
        if (refreshed) {
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
      throw Exception('네트워크 오류: $e');
    }
  }

  Future<dynamic> put(String endpoint, {dynamic data}) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
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
      throw Exception('네트워크 오류: $e');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
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
      throw Exception('네트워크 오류: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
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
      throw Exception('서버 오류: ${response.statusCode}');
    }
  }
}