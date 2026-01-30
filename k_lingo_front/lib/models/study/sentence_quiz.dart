abstract class SentenceQuiz {
  final int sentenceId;
  final String question; // 문제(뜻)
  final String hint;
  final String originalSentence;
  final String type;
  final String? youtubeId;
  final int? startTime;
  final int? endTime;

  SentenceQuiz({
    required this.sentenceId,
    required this.question,
    required this.hint,
    required this.originalSentence,
    required this.type,
    this.youtubeId,
    this.startTime,
    this.endTime,
  });

  factory SentenceQuiz.fromJson(Map<String, dynamic> json) {
    // 1. 서버에서 type을 주면 그걸 쓰고, 없으면 null
    String? type = json['type']?.toString();

    // 2. type이 없으면, 데이터 생김새를 보고 추측(Inference) 하기!
    if (type == null) {
      if (json.containsKey('shuffledWords')) {
        type = 'SCRAMBLE';
      } else if (json.containsKey('blankSentence')) {
        type = 'BLANK';
      } else {
        type = 'UNKNOWN';
      }
    }

    // 3. 결정된 type으로 객체 생성
    if (type == 'BLANK') {
      return BlankQuiz.fromJson(json);
    } else if (type == 'SCRAMBLE') {
      return ScrambleQuiz.fromJson(json);
    }
    
    throw Exception('Unknown quiz type: $type / Raw Json: $json');
    }
}

class BlankQuiz extends SentenceQuiz {
  final String blankSentence;
  final String blankAnswer;

  BlankQuiz({
    required super.sentenceId,
    required super.question,
    required super.hint,
    required super.originalSentence,
    required this.blankSentence,
    required this.blankAnswer,
    String? youtubeId, int? startTime, int? endTime,
  }) : super(
        type: 'BLANK', 
        youtubeId: youtubeId, 
        startTime: startTime, 
        endTime: endTime,
    );

  factory BlankQuiz.fromJson(Map<String, dynamic> json) {
    return BlankQuiz(
      sentenceId: json['sentenceId'] ?? 0,
      question: json['question'] ?? '', 
      hint: json['hint'] ?? '', 
      originalSentence: json['originalSentence'] ?? '',
      blankSentence: json['blankSentence'] ?? '',
      blankAnswer: json['blankAnswer'] ?? '',
      youtubeId: json['youtubeId'],
      startTime: json['startTime'],
      endTime: json['endTime'],
    );
  }
}

class ScrambleQuiz extends SentenceQuiz {
  final List<String> shuffledWords;

  ScrambleQuiz({
    required super.sentenceId,
    required super.question,
    required super.hint,
    required super.originalSentence,
    required this.shuffledWords,
  }) : super(type: 'SCRAMBLE');

  factory ScrambleQuiz.fromJson(Map<String, dynamic> json) {
    return ScrambleQuiz(
      sentenceId: json['sentenceId'] ?? 0,
      question: json['question'] ?? '',
      hint: json['hint'] ?? '',
      originalSentence: json['originalSentence'] ?? '',
      // 👇 리스트가 null이면 빈 리스트 반환
      shuffledWords: (json['shuffledWords'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}