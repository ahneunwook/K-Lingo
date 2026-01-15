class Stage {
  final int id;
  final int stageOrder;
  final String title;
  final int bestScore;
  final bool isCleared;
  final bool isLocked;

  Stage({
    required this.id,
    required this.stageOrder,
    required this.title,
    required this.bestScore,
    required this.isCleared,
    required this.isLocked,
  });

  factory Stage.fromJson(Map<String, dynamic> json) {
    return Stage(
      id: json['id'],
      stageOrder: json['stageOrder'],
      title: json['title'],
      bestScore: json['bestScore'],
      isCleared: json['isCleared'],
      isLocked: json['isLocked'],
    );
  }
}