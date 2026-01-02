import 'dart:io';

class AppConfig {
  // 환경 설정
  static const String appName = 'KoreanMate';
  static const String apiVersion = 'v1';
  
  // API Base URL
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/api/$apiVersion';
    } else {
      return 'http://localhost:8080/api/$apiVersion';
    }
  }
  
  // 타임아웃 설정
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
