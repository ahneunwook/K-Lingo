import 'dart:io';

class AppConfig {
  // 환경 설정
  static const String appName = 'KoreanMate';
  static const String apiVersion = 'v1';
  static const String _port = '8080'; // 포트 번호
  
  // [1] 호스트 IP 결정 로직을 따로 분리 (재사용을 위해)
  static String get _host {
    if (Platform.isAndroid) {
      return '10.0.2.2'; // 안드로이드 에뮬레이터
    } else if (Platform.isIOS) {
      return 'localhost'; // iOS 시뮬레이터
    } else {
      return 'localhost'; // 웹, 데스크톱 등
    }
    // 실기기 테스트 시 위 코드를 주석 처리하고 아래 IP 사용
    // return '192.168.0.x'; 
  }

  static String get baseUrl {
    return 'http://$_host:$_port/api/$apiVersion';
  }

  // API 경로(/api/v1)가 없는 순수 도메인이 필요할 때 사용
  static String get serverUrl {
    return 'http://$_host:$_port';
  }
  
  // 타임아웃 설정
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}