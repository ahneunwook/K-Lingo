import '../models/quest/quest.dart';
import 'api_service.dart';

class QuestService {
  final ApiService _apiService = ApiService();

  /// 오늘의 퀘스트 목록 조회
  Future<List<Quest>> getTodayQuests() async {
    try {
      print('🔍 [QuestService] 퀘스트 목록 조회 시작');
      final response = await _apiService.get('/quests/today');
      print('✅ [QuestService] 응답 받음: $response');

      if (response['data'] != null) {
        final List<dynamic> list = response['data'];
        print('✅ [QuestService] 퀘스트 개수: ${list.length}');
        return list.map((json) => Quest.fromJson(json)).toList();
      } else {
        print('⚠️ [QuestService] data가 null');
        return [];
      }
    } catch (e) {
      print('❌ QuestService: 퀘스트 목록 조회 실패 - $e');
      rethrow;
    }
  }

  /// 보상 수령하기
  Future<QuestReward> claimReward(int memberQuestId) async {
    try {
      print('🔍 [QuestService] 보상 요청 시작');
      print('🔍 [QuestService] memberQuestId: $memberQuestId');
      print('🔍 [QuestService] 요청 경로: /quests/$memberQuestId/claim');
      
      final response = await _apiService.post('/quests/$memberQuestId/claim');
      
      print('✅ [QuestService] 보상 응답 받음: $response');

      if (response['data'] != null) {
        print('✅ [QuestService] 보상 데이터 파싱 시작');
        final reward = QuestReward.fromJson(response['data']);
        print('✅ [QuestService] 보상 파싱 완료: rewardXp=${reward.rewardXp}');
        return reward;
      } else {
        print('❌ [QuestService] response[data]가 null');
        print('❌ [QuestService] 전체 응답: $response');
        throw Exception('보상 데이터를 받을 수 없습니다.');
      }
    } catch (e, stackTrace) {
      print('❌ QuestService: 보상 수령 실패 - $e');
      print('❌ StackTrace: $stackTrace');
      rethrow;
    }
  }
}