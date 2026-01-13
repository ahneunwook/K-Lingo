import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';    
import '../../models/word/stage.dart'; // WordStage 모델 import
import '../services/api_service.dart';
import '../models/common/api_response.dart';

class WordStageService {

  final ApiService _apiService = ApiService();
    
  // 특정 카테고리의 스테이지 목록 가져오기
  Future<List<WordStage>> getStages(int categoryId) async {
    try {
      // 1. ApiService를 이용해 GET 요청
      // 쿼리 파라미터(?categoryId=...)를 URL에 포함시켜야 합니다.
      final responseJson = await _apiService.get('/stages?categoryId=$categoryId');

      // 2. 응답 데이터를 ApiResponse 객체로 변환
      final apiResponse = ApiResponse<List<WordStage>>.fromJson(
        responseJson,
        (data) {
          // data는 JSON List 형태이므로 map을 통해 WordStage 객체 리스트로 변환
          return (data as List)
              .map((item) => WordStage.fromJson(item))
              .toList();
        },
      );

      // 3. 성공 여부 확인 및 데이터 반환
      if (apiResponse.success) {
        return apiResponse.data ?? [];
      } else {
        throw Exception(apiResponse.message ?? '스테이지 목록을 불러오지 못했습니다.');
      }
    } catch (e) {
      print('WordStageService Error: $e');
      rethrow;
    }
  }
}