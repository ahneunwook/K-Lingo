import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:k_lingo_front/config/app_config.dart';    
import 'package:k_lingo_front/models/study/chapter.dart';
import 'package:k_lingo_front/services/api_service.dart';
import 'package:k_lingo_front/models/common/api_response.dart';

class ChapterService {
  final ApiService _apiService = ApiService();

  Future<List<Chapter>> getChapters(String type) async {
    try {
      final responseJson = await _apiService.get('/study/chapters?type=$type');

      final apiResponse = ApiResponse<List<Chapter>>.fromJson(
        responseJson,
        (data) {
          return (data as List)
              .map((item) => Chapter.fromJson(item))
              .toList();
        },
      );

      if (apiResponse.success) {
        return apiResponse.data ?? [];
      } else {
        throw Exception(apiResponse.message ?? '챕터 목록을 불러오지 못했습니다.');
      }
    } catch (e) {
      print('ChapterService Error: $e');
      rethrow;
    }
  }
}