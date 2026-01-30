import 'package:k_lingo_front/services/api_service.dart'; // 기존에 쓰시던 ApiService
import 'package:k_lingo_front/models/study/sentence_quiz.dart';
import 'package:k_lingo_front/models/study/sentence_submit_res.dart';
import 'package:k_lingo_front/models/common/api_response.dart';

class SentenceService {
  final ApiService _apiService = ApiService();

  // 1. 퀴즈 목록 가져오기 (GET)
  Future<List<SentenceQuiz>> getChapterQuizzes(int chapterId) async {
    try {
      // 백엔드 API 호출 (/sentence/quiz/chapter/{id})
      final responseJson = await _apiService.get(
        '/sentence/quiz/chapter/$chapterId?count=20', // 한 번에 20개 가져오기
      );

      // 공통 응답 처리 (ApiResponse)
      final apiResponse = ApiResponse<List<SentenceQuiz>>.fromJson(
        responseJson,
        (data) => (data as List)
            .map((item) => SentenceQuiz.fromJson(item)) // 여기서 다형성(Blank/Scramble) 처리됨
            .toList(),
      );

      if (apiResponse.success) {
        return apiResponse.data ?? [];
      } else {
        throw Exception(apiResponse.message);
      }
    } catch (e) {
      print('❌ Quiz Load Error: $e');
      rethrow;
    }
  }

  // 2. 정답 제출하기 (POST)
  Future<SentenceSubmitRes> submitQuiz({
    required int chapterId,
    required int sentenceId,
    required String userAnswer,
  }) async {
    try {
      final body = {
        "chapterId": chapterId,
        "sentenceId": sentenceId,
        "userAnswer": userAnswer,
      };

      // 백엔드 API 호출 (/sentence/quiz/submit)
      final responseJson = await _apiService.post(
        '/sentence/quiz/submit',
        data: body,
      );

      final apiResponse = ApiResponse<SentenceSubmitRes>.fromJson(
        responseJson,
        (data) => SentenceSubmitRes.fromJson(data),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      } else {
        throw Exception(apiResponse.message);
      }
    } catch (e) {
      print('❌ Quiz Submit Error: $e');
      rethrow;
    }
  }
}