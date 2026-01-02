import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _authToken;

  // 토큰 설정
  void setAuthToken(String token) {
    _authToken = token;
  }

  // 토큰 제거
  void clearAuthToken() {
    _authToken = null;
  }

  // 헤더 생성
  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // GET 요청
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}$endpoint'),
        headers: _getHeaders(),
      ).timeout(AppConfig.connectionTimeout);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // POST 요청
  Future<dynamic> post(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}$endpoint'),
        headers: _getHeaders(),
        body: data != null ? jsonEncode(data) : null,
      ).timeout(AppConfig.connectionTimeout);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // PUT 요청
  Future<dynamic> put(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}$endpoint'),
        headers: _getHeaders(),
        body: data != null ? jsonEncode(data) : null,
      ).timeout(AppConfig.connectionTimeout);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // DELETE 요청
  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}$endpoint'),
        headers: _getHeaders(),
      ).timeout(AppConfig.connectionTimeout);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // 응답 처리
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      try {
        return jsonDecode(response.body);
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
