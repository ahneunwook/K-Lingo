// 퀘스트 목록용 모델 (QuestResponse 대응)
class Quest {
  final int id;
  final String title;
  final String description;
  final int rewardXp;
  final int currentCount;
  final int targetCount;
  final bool isCompleted;
  final bool rewardClaimed;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardXp,
    required this.currentCount,
    required this.targetCount,
    required this.isCompleted,
    required this.rewardClaimed,
  });

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      rewardXp: json['rewardXp'] ?? 0,
      currentCount: json['currentCount'] ?? 0,
      targetCount: json['targetCount'] ?? 1,
      isCompleted: json['completed'] ?? false,
      rewardClaimed: json['rewardClaimed'] ?? false,
    );
  }
}

// 보상 수령 결과 모델 (QuestRewardResponse 대응)
class QuestReward {
  final int rewardXp;
  final int currentXp;
  final int currentLevel;
  final bool isLevelUp;
  final int previousLevel;
  final int requiredXp;
  final int xpPercentage;

  QuestReward({
    required this.rewardXp,
    required this.currentXp,
    required this.currentLevel,
    required this.isLevelUp,
    required this.previousLevel,
    required this.requiredXp,
    required this.xpPercentage,
  });

  factory QuestReward.fromJson(Map<String, dynamic> json) {
    return QuestReward(
      rewardXp: json['rewardXp'] ?? 0,
      currentXp: json['currentXp'] ?? 0,
      currentLevel: json['currentLevel'] ?? 1,
      isLevelUp: json['isLevelUp'] ?? false,
      previousLevel: json['previousLevel'] ?? 1,
      requiredXp: json['requiredXp'] ?? 100,
      xpPercentage: json['xpPercentage'] ?? 0,
    );
  }
}