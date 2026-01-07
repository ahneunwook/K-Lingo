import 'dart:io';

class AppConfig {
  // 환경 설정
  static const String appName = 'KoreanMate';
  static const String apiVersion = 'v1';
  static const String _port = '8080'; // 포트 번호 분리
  
  // API Base URL
  static String get baseUrl {
    String host;
    
    if (Platform.isAndroid) {
      // 안드로이드 에뮬레이터 전용 IP
      host = '10.0.2.2';
    } else if (Platform.isIOS) {
      // iOS 시뮬레이터는 localhost보다 127.0.0.1이 더 안정적임
      host = '127.0.0.1';
    } else {
      // 그 외 (웹, 데스크톱 등)
      host = 'localhost';
    }

    // 만약 "실제 폰"을 연결해서 테스트한다면 위 코드를 무시하고
    // 아래 주석을 풀어서 내 컴퓨터 IP를 직접 적어야 합니다.
    // host = '192.168.0.x'; 

    return 'http://$host:$_port/api/$apiVersion';
  }
  
  // 타임아웃 설정
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}