import '../models/member/member_progress.dart';
import 'api_service.dart';

class MemberService {
  final ApiService _apiService = ApiService();

  /// 내 학습 진행 상황 조회
  /// GET /members/me/progress
  Future<MemberProgress> getMyProgress() async {
    try {
      final response = await _apiService.get('/members/me/progress');
      
      if (response['data'] != null) {
        return MemberProgress.fromJson(response['data']);
      } else {
        throw Exception('데이터가 비어있습니다.');
      }
    } catch (e) {
      print('❌ MemberService: 진행 상황 조회 실패 - $e');
      rethrow; // 화면에서 에러 처리를 할 수 있도록 예외를 다시 던짐
    }
  }

  Future<MemberProfile> getMyProfile() async {
    try {
      final response = await _apiService.get('/members/me/profile');
      
      if (response['data'] != null) {
        return MemberProfile.fromJson(response['data']);
      } else {
        throw Exception('프로필 데이터가 비어있습니다.');
      }
    } catch (e) {
      print('❌ MemberService: 프로필 조회 실패 - $e');
      rethrow;
    }
  }
}