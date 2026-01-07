import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';    
import '../../models/word/word_category.dart';
import '../services/api_service.dart';
import '../models/common/api_response.dart';

class WordCategoryService {

  final ApiService _apiService = ApiService();
    
    // 카테고리 목록 가져오기
  Future<List<WordCategory>> getCategories() async {
    try {
      // 1. ApiService를 이용해 GET 요청
      // ApiService 내부에서 이미 BaseURL과 Header(토큰 포함)를 처리하므로
      // 엔드포인트('/words/categories')만 넘겨주면 됩니다.
      final responseJson = await _apiService.get('/words/categories');

      // 2. 응답 데이터를 ApiResponse 객체로 변환
      // 제네릭 <List<WordCategory>>를 사용하여 타입을 명확히 합니다.
      final apiResponse = ApiResponse<List<WordCategory>>.fromJson(
        responseJson,
        (data) {
          // data는 JSON List 형태이므로 map을 통해 WordCategory 객체 리스트로 변환
          return (data as List)
              .map((item) => WordCategory.fromJson(item))
              .toList();
        },
      );
    // 3. 성공 여부 확인 및 데이터 반환
      if (apiResponse.success) {
        return apiResponse.data ?? [];
      } else {
        throw Exception(apiResponse.message ?? '카테고리 목록을 불러오지 못했습니다.');
      }
    } catch (e) {
      // 에러 발생 시 로그 출력 후 다시 던짐 (UI에서 처리하도록)
      print('WordService Error: $e');
      rethrow;
    }
  }
}