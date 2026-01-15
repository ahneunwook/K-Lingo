import 'package:k_lingo_front/models/member/daily_tip.dart';

class MemberProgress {
  final String nickname;
  final int level;
  final int currentXp;
  final int requiredXp;
  final int remainingXp;
  final int xpPercentage;
  final int streakDays;
  final int totalAttendanceDays;
  final int totalCompletedQuests;

  final DailyTip? dailyTip; 
  final List<SectionProgress> sections; 

  MemberProgress({
    required this.nickname,
    required this.level,
    required this.currentXp,
    required this.requiredXp,
    required this.remainingXp,
    required this.xpPercentage,
    required this.streakDays,
    required this.totalAttendanceDays,
    required this.totalCompletedQuests,
    this.dailyTip,
    required this.sections,
  });

  // JSON 데이터를 Dart 객체로 변환하는 팩토리 생성자
  factory MemberProgress.fromJson(Map<String, dynamic> json) {
    return MemberProgress(
      nickname: json['nickname'] ?? '',
      level: json['level'] ?? 1,
      currentXp: json['currentXp'] ?? 0,
      requiredXp: json['requiredXp'] ?? 100,
      remainingXp: json['remainingXp'] ?? 100,
      xpPercentage: json['xpPercentage'] ?? 0,
      streakDays: json['streakDays'] ?? 0,
      totalAttendanceDays: json['totalAttendanceDays'] ?? 0,
      totalCompletedQuests: json['totalCompletedQuests'] ?? 0,

      dailyTip: json['dailyTipRes'] != null 
          ? DailyTip.fromJson(json['dailyTipRes']) 
          : null, 
          
      sections: (json['sections'] as List?)
          ?.map((item) => SectionProgress.fromJson(item))
          .toList() ?? [], // null이면 빈 리스트 반환
    );
  }

  // UI에서 'New Student' 같은 칭호를 레벨별로 보여주고 싶다면 
  // 이런 getter를 모델 안에 추가해두면 편리합니다.
  String get rankTitle {
    if (level < 5) return 'New Student';
    if (level < 10) return 'Junior';
    if (level < 20) return 'Senior';
    return 'Master';
  }
}

class SectionProgress {
  final String title;
  final String description;
  final String type; // 'TOPIC', 'SENTENCE', 'KDRAMA', 'KPOP'
  final int progress; // 0 ~ 100

  SectionProgress({
    required this.title,
    required this.description,
    required this.type,
    required this.progress,
  });

  factory SectionProgress.fromJson(Map<String, dynamic> json) {
    return SectionProgress(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'TOPIC',
      progress: json['progress'] ?? 0,
    );
  }

  // UI에서 사용할 아이콘을 여기서 정의하면 편합니다
  String get icon {
    switch (type) {
      case 'TOPIC': return '📚';
      case 'SENTENCE': return '✍️';
      case 'KPOP': return '🎵';
      case 'KDRAMA': return '📺';
      default: return '❓';
    }
  }
}