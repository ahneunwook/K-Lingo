class WordQuizRes {
  final int wordId;
  final String content;       // 문제 지문 (영어: Apple)
  final String meaning;       // 정답 (한국어: 사과)
  final String quizType;      // CHOICE, WRITING, LISTENING
  final List<String> options; // 보기 (한국어: [사과, 포도, 배, 감])
  final String? audioUrl;
  final String? pronunciation;

  WordQuizRes({
    required this.wordId,
    required this.content,
    required this.meaning,
    required this.quizType,
    required this.options,
    this.audioUrl,
    this.pronunciation,
  });

  factory WordQuizRes.fromJson(Map<String, dynamic> json) {
    return WordQuizRes(
      wordId: json['wordId'],
      content: json['content'], 
      meaning: json['meaning'],
      quizType: json['quizType'],
      // JSON 리스트를 문자열 리스트로 안전하게 변환
      options: List<String>.from(json['options'] ?? []),
      audioUrl: json['audioUrl'],
      pronunciation: json['pronunciation'],
    );
  }
}