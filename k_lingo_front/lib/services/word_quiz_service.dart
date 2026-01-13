import '../models/common/api_response.dart';
import '../models/word/quiz_submission.dart'; // DTO 파일 (CheckReq, ResultRes)
import '../models/word/word_quiz.dart';  // 퀴즈 문제 모델
import 'api_service.dart';

class WordQuizService {
  // 만드신 싱글톤 ApiService 가져오기
  final ApiService _apiService = ApiService();

  // 1. 퀴즈 문제 조회
  // GET /quizzes?stageId={id}
  Future<List<WordQuizRes>> getQuizWords(int stageId) async {
    try {
      // ApiService가 헤더(토큰)와 BaseURL을 알아서 처리함
      final responseJson = await _apiService.get('/quizzes?stageId=$stageId');

      final apiResponse = ApiResponse<List<WordQuizRes>>.fromJson(
        responseJson,
        (data) => (data as List)
            .map((item) => WordQuizRes.fromJson(item))
            .toList(),
      );

      if (apiResponse.success) {
        return apiResponse.data ?? [];
      } else {
        throw Exception(apiResponse.message);
      }
    } catch (e) {
      print('퀴즈 조회 실패: $e');
      rethrow;
    }
  }

  // 2. 퀴즈 제출 및 채점
  // POST /quizzes/submit?stageId={id}
  // Body: List<WordQuizCheckReq>
  Future<WordQuizResultRes> submitQuiz(int stageId, List<WordQuizCheckReq> answers) async {
    try {
      // List<Object> -> List<Map> 변환
      // (ApiService.post의 data 파라미터를 dynamic으로 바꿨기 때문에 리스트 전송 가능)
      final bodyData = answers.map((e) => e.toJson()).toList();

      final responseJson = await _apiService.post(
        '/quizzes/submit?stageId=$stageId',
        data: bodyData, 
      );

      final apiResponse = ApiResponse<WordQuizResultRes>.fromJson(
        responseJson,
        (json) => WordQuizResultRes.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success) {
        return apiResponse.data!;
      } else {
        throw Exception(apiResponse.message);
      }
    } catch (e) {
      print('퀴즈 제출 실패: $e');
      rethrow;
    }
  }
}