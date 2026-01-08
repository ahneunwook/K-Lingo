// 1. [요청] 답안 제출용 DTO
class WordQuizCheckReq {
  final int wordId;
  final String userAnswer;

  WordQuizCheckReq({
    required this.wordId,
    required this.userAnswer,
  });

  Map<String, dynamic> toJson() {
    return {
      'wordId': wordId,
      'userAnswer': userAnswer,
    };
  }
}

// 2. [응답] 결과 확인용 DTO
class WordQuizResultRes {
  final int totalCount;
  final int correctCount;
  final int incorrectCount;
  final int score;
  final bool isPassed;

  WordQuizResultRes({
    required this.totalCount,
    required this.correctCount,
    required this.incorrectCount,
    required this.score,
    required this.isPassed,
  });

  factory WordQuizResultRes.fromJson(Map<String, dynamic> json) {
    return WordQuizResultRes(
      totalCount: json['totalCount'],
      correctCount: json['correctCount'],
      incorrectCount: json['incorrectCount'],
      score: json['score'],
      isPassed: json['isPassed'] ?? json['passed'] ?? false, 
    );
  }
}