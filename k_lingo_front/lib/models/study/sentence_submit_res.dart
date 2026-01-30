class SentenceSubmitRes {
  final bool isCorrect;
  final String userAnswer;
  final String correctAnswer;
  final String? voiceFileUrl;

  SentenceSubmitRes({
    required this.isCorrect,
    required this.userAnswer,
    required this.correctAnswer,
    this.voiceFileUrl,
  });

  factory SentenceSubmitRes.fromJson(Map<String, dynamic> json) {
    return SentenceSubmitRes(
      isCorrect: json['isCorrect'] ?? false,
      userAnswer: json['userAnswer'] ?? '',
      correctAnswer: json['correctAnswer'] ?? '',
      voiceFileUrl: json['voiceFileUrl'],
    );
  }
}