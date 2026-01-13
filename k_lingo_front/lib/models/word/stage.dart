class WordStage {
  final int id;
  final int stageOrder;
  final String title;
  final int bestScore;
  final bool isCleared;
  final bool isLocked;

  WordStage({
    required this.id,
    required this.stageOrder,
    required this.title,
    required this.bestScore,
    required this.isCleared,
    required this.isLocked,
  });

  factory WordStage.fromJson(Map<String, dynamic> json) {
    return WordStage(
      id: json['id'],
      stageOrder: json['stageOrder'],
      title: json['title'],
      bestScore: json['bestScore'],
      isCleared: json['isCleared'],
      isLocked: json['isLocked'],
    );
  }
}