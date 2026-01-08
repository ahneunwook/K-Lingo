import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../services/word_quiz_service.dart';
import '../../models/word/word_quiz.dart';      
import '../../models/word/quiz_submission.dart';
import '../../config/app_config.dart';

class QuizScreen extends StatefulWidget {
  final int stageId; // 생성자에서 직접 받음

  const QuizScreen({Key? key, required this.stageId}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final WordQuizService _quizService = WordQuizService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TextEditingController _answerController = TextEditingController();

  List<WordQuizRes>? _quizzes;
  final Map<int, String> _userAnswers = {}; // 사용자가 선택한 답안 저장
  
  int _currentIndex = 0;
  String? _selectedAnswer; // 현재 선택한 답 (화면 표시용)
  String? _tempSelected;   // 정답 확인 전 선택한 답
  bool _isAnswered = false; // 정답 확인 버튼 눌렀는지 여부
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _loadQuiz() async {
    try {
      // widget.stageId를 바로 사용
      final quizzes = await _quizService.getQuizWords(widget.stageId);
      setState(() {
        _quizzes = quizzes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // 답안 선택 처리
  void _handleAnswerSelect(String answer) {
    if (_isAnswered) return;

    setState(() {
      _selectedAnswer = answer;
      _isAnswered = true; // 정답 확인 상태로 변경 (바텀시트 올라옴)
      
      final currentQuiz = _quizzes![_currentIndex];
      
      // 사용자 답안 저장 (나중에 제출용)
      _userAnswers[currentQuiz.wordId] = answer;
      
      // 리스닝이나 쓰기 문제일 경우, 정답 확인 시 소리 재생 등 추가 액션 가능
    });
  }

  // 다음 문제로 이동
  void _handleNext() {
    if (_currentIndex < _quizzes!.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _tempSelected = null;
        _isAnswered = false;
        _answerController.clear();
      });
    } else {
      _submitQuiz();
    }
  }

  // 최종 제출
  Future<void> _submitQuiz() async {
    try {
      // DTO 변환 (WordQuizCheckReq에는 quizType이 없음 -> 제거함)
      final answers = _quizzes!.map((quiz) {
        return WordQuizCheckReq(
          wordId: quiz.wordId,
          userAnswer: _userAnswers[quiz.wordId] ?? '',
        );
      }).toList();

      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final result = await _quizService.submitQuiz(widget.stageId, answers);

      if (mounted) {
        Navigator.pop(context); // 로딩 닫기
        // 결과 화면으로 교체
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
            builder: (context) => QuizResultScreen(
                result: result,
                stageId: widget.stageId,
          ),
          ),
          result: true,
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // 로딩 닫기
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('제출 실패: $e')),
        );
      }
    }
  }

  Future<void> _playAudio(String? audioUrl) async {
    if (audioUrl == null || audioUrl.isEmpty) return;
    
    try {
      String finalUrl = audioUrl;

     if (!audioUrl.startsWith('http')) {
        finalUrl = '${AppConfig.baseUrl}$audioUrl'; 
    }   

      print('재생 URL: $finalUrl'); 
      await _audioPlayer.play(UrlSource(finalUrl));
    } catch (e) {
      print('Audio play error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F3FF),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF9C27B0))),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('오류 발생: $_error'),
              ElevatedButton(onPressed: _loadQuiz, child: const Text('재시도')),
            ],
          ),
        ),
      );
    }

    if (_quizzes == null || _quizzes!.isEmpty) {
      return const Scaffold(body: Center(child: Text('퀴즈가 없습니다.')));
    }

    final currentQuiz = _quizzes![_currentIndex];
    final progress = (_currentIndex + 1) / _quizzes!.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F3FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(progress),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildQuizContent(currentQuiz),
              ),
            ),
            // 정답을 선택했을 때만 바텀시트(O/X 결과) 표시
            if (_isAnswered) _buildBottomSheet(currentQuiz),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double progress) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '${_currentIndex + 1} / ${_quizzes!.length}',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF9C27B0)),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48), // 아이콘 공간만큼 띄워줌
        ],
      ),
    );
  }

  Widget _buildQuizContent(WordQuizRes quiz) {
    switch (quiz.quizType) {
      case 'WRITING':
        return _buildWriting(quiz);
      case 'LISTENING':
        return _buildListening(quiz);
      case 'CHOICE':
      default:
        return _buildMultipleChoice(quiz);
    }
  }

  // --- 1. 객관식 UI ---
  Widget _buildMultipleChoice(WordQuizRes quiz) {
    return Column(
      children: [
        _buildQuestionCard('객관식', '다음 단어의 뜻을 고르세요', quiz),
        const SizedBox(height: 24),
        ...quiz.options.map((option) {
          return _buildOptionButton(option, quiz.meaning);
        }).toList(),
        const SizedBox(height: 16),
        // 아직 정답 선택 안 했으면 확인 버튼 표시
        if (!_isAnswered) _buildSubmitButton('정답 확인'),
      ],
    );
  }

  // --- 2. 주관식 UI ---
  Widget _buildWriting(WordQuizRes quiz) {
    return Column(
      children: [
        _buildQuestionCard('주관식', '다음 단어의 뜻을 입력하세요', quiz),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: _isAnswered
                ? Border.all(
                    color: _answerController.text.trim() == quiz.meaning
                        ? Colors.green
                        : Colors.red,
                    width: 3,
                  )
                : Border.all(color: Colors.transparent),
          ),
          child: TextField(
            controller: _answerController,
            enabled: !_isAnswered,
            autofocus: false, // 필요 시 true
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              hintText: '정답 입력',
              border: InputBorder.none,
            ),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty && !_isAnswered) {
                _handleAnswerSelect(value.trim());
              }
            },
          ),
        ),
        const SizedBox(height: 16),
        if (!_isAnswered) _buildSubmitButton('정답 제출'),
      ],
    );
  }

  // --- 3. 듣기 평가 UI ---
  Widget _buildListening(WordQuizRes quiz) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildBadge('듣기'),
              const SizedBox(height: 16),
              const Text('들려주는 단어의 뜻은?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              InkWell(
                onTap: () => _playAudio(quiz.audioUrl),
                child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFFEC407A)]),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9C27B0).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.volume_up, size: 60, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              const Text('🔊 눌러서 듣기', style: TextStyle(fontSize: 14, color: Colors.black54)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ...quiz.options.map((option) => _buildOptionButton(option, quiz.meaning)).toList(),
        const SizedBox(height: 16),
        if (!_isAnswered) _buildSubmitButton('정답 확인'),
      ],
    );
  }

  // --- 공통 위젯들 ---
  Widget _buildQuestionCard(String badge, String title, WordQuizRes quiz) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildBadge(badge),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Text(
            quiz.content,
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF9C27B0)),
            textAlign: TextAlign.center,
          ),
          if (quiz.pronunciation != null) ...[
            const SizedBox(height: 8),
            Text('[ ${quiz.pronunciation} ]', style: const TextStyle(fontSize: 16, color: Colors.black54)),
          ]
        ],
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFF3E5F5), Color(0xFFFCE4EC)]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF9C27B0))),
    );
  }

  Widget _buildOptionButton(String option, String correctAnswer) {
    // 임시 선택된 상태 or 최종 확인 상태에 따라 UI 변경
    final isSelected = _isAnswered ? _selectedAnswer == option : _tempSelected == option;
    final isCorrect = option == correctAnswer;

    Color? bgColor = Colors.white;
    Color borderColor = Colors.grey[300]!;
    double borderWidth = 2;
    Widget? trailing;

    if (_isAnswered) {
      // 정답 확인 후
      if (isCorrect) {
        bgColor = Colors.green[50];
        borderColor = Colors.green;
        trailing = const Icon(Icons.check, color: Colors.green);
      } else if (isSelected) {
        bgColor = Colors.red[50];
        borderColor = Colors.red;
        trailing = const Icon(Icons.close, color: Colors.red);
      }
    } else {
      // 정답 확인 전 (선택 중)
      if (isSelected) {
        bgColor = const Color(0xFFF3E5F5);
        borderColor = const Color(0xFF9C27B0);
        borderWidth = 3;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: _isAnswered ? null : () => setState(() => _tempSelected = option),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: borderWidth),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(child: Text(option, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500))),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(String text) {
    bool isEnabled = false;
    final currentQuiz = _quizzes![_currentIndex];

    if (currentQuiz.quizType == 'WRITING') {
      isEnabled = _answerController.text.trim().isNotEmpty;
    } else {
      isEnabled = _tempSelected != null;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled
            ? () {
                if (currentQuiz.quizType == 'WRITING') {
                  _handleAnswerSelect(_answerController.text.trim());
                } else {
                  _handleAnswerSelect(_tempSelected!);
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          backgroundColor: const Color(0xFF9C27B0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  // --- O/X 결과 바텀시트 ---
  Widget _buildBottomSheet(WordQuizRes quiz) {
    // 공백 제거 후 비교 (주관식 대비)
    final bool isCorrect = _selectedAnswer!.replaceAll(' ', '') == quiz.meaning.replaceAll(' ', '');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(isCorrect ? Icons.check_circle : Icons.cancel, color: isCorrect ? Colors.green : Colors.red, size: 32),
              const SizedBox(width: 12),
              Text(isCorrect ? '정답입니다!' : '오답입니다', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isCorrect ? Colors.green : Colors.red)),
            ],
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('정답: ${quiz.meaning}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleNext,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: const Color(0xFF9C27B0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _currentIndex < _quizzes!.length - 1 ? '다음 문제' : '결과 보기',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// ---------------------------------------------
// 결과 화면
// ---------------------------------------------
class QuizResultScreen extends StatelessWidget {
  final WordQuizResultRes result;
  final int stageId;

  const QuizResultScreen({
    Key? key,
    required this.result,
    required this.stageId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPassed = result.isPassed;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F3FF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 아이콘
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: isPassed 
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        isPassed ? Icons.check_circle : Icons.close,
                        size: 80,
                        color: isPassed ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 제목
                  Text(
                    isPassed ? '통과!' : '아쉬워요',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isPassed 
                        ? '7문제 이상 맞췄어 합니다'
                        : '7문제 이상 맞춰야 합니다',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 점수 카드
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF3E5F5), Color(0xFFFCE4EC)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // 큰 점수 표시
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Color(0xFF9C27B0), Color(0xFFEC407A)],
                              ).createShader(bounds),
                              child: Text(
                                '${result.correctCount}',
                                style: const TextStyle(
                                  fontSize: 72,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Text(
                              ' / ${result.totalCount}',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '친구 사귀기 (일상 회화)',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 목록으로 버튼
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      icon: const Icon(Icons.home_outlined),
                      label: const Text(
                        '목록으로',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(20),
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(
                          color: Colors.grey[400]!,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}