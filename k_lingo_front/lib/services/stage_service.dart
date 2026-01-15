import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:k_lingo_front/config/app_config.dart';    
import 'package:k_lingo_front/models/study/stage.dart';
import 'package:k_lingo_front/services/api_service.dart';
import 'package:k_lingo_front/models/common/api_response.dart';

class StageService {
  final ApiService _apiService = ApiService();
    
  Future<List<Stage>> getStages(int chapterId) async {
    try {
      final responseJson = await _apiService.get('/study/stages?chapterId=$chapterId');

      final apiResponse = ApiResponse<List<Stage>>.fromJson(
        responseJson,
        (data) {
          return (data as List)
              .map((item) => Stage.fromJson(item))
              .toList();
        },
      );

      if (apiResponse.success) {
        return apiResponse.data ?? [];
      } else {
        throw Exception(apiResponse.message ?? '스테이지 목록을 불러오지 못했습니다.');
      }
    } catch (e) {
      print('StageService Error: $e');
      rethrow;
    }
  }
}