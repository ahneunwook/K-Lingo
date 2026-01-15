class DailyTip {
  final int tipId;
  final String title;
  final String category; // "CULTURE", "MOTIVATION" 등
  final String content;
  final String tag;
  final String icon;

  DailyTip({
    required this.tipId,
    required this.title,
    required this.category,
    required this.content,
    required this.tag,
    required this.icon,
  });

  factory DailyTip.fromJson(Map<String, dynamic> json) {
    return DailyTip(
      tipId: json['tipId'] ?? 0,
      title: json['title'] ?? 'Daily Tip',
      category: json['category'] ?? 'STUDY',
      content: json['content'] ?? 'Keep going!',
      tag: json['tag'] ?? '#Learning',
      icon: json['icon'] ?? '💡',
    );
  }
}