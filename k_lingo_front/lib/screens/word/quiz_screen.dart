import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'dart:math';
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

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  final WordQuizService _quizService = WordQuizService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  // final TextEditingController _answerController = TextEditingController(); // 삭제됨 (더 이상 안 씀)

  static const int maxAttempts = 2;
  int wrongCount = 0;

  List<WordQuizRes>? _quizzes;
  final Map<int, String> _userAnswers = {};
  
  int _currentIndex = 0;
  String? _selectedAnswer;
  String? _tempSelected;
  bool _isAnswered = false;
  bool _isLoading = true;
  String? _error;
  int _currentAttempts = 0;

  // [추가] 블록 맞추기용 변수들
  List<String> _shuffledBlocks = []; // 섞인 보기 글자들
  List<String> _selectedBlocks = []; // 사용자가 선택한(정답칸에 올라간) 글자들
  bool _isBlocksInitialized = false; // 현재 문제에 대해 블록이 생성되었는지 체크

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  
  @override
  void initState() {
    super.initState();
    _loadQuiz();

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // 진동 애니메이션 설정
    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _shakeController.reset();
        }
      });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    // _answerController.dispose(); // 삭제됨
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _loadQuiz() async {
    try {
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

  void _shakeScreen() {
    HapticFeedback.heavyImpact();
    _shakeController.forward();
  }

  // 답안 선택 처리 (공통)
  void _handleAnswerSelect(String answer) {
    if (_isAnswered) return;

    final currentQuiz = _quizzes![_currentIndex];
    // 공백 제거 후 비교 (블록 사이에 공백이 들어가도 정답 처리)
    final isCorrect = answer.replaceAll(' ', '') == currentQuiz.meaning.replaceAll(' ', '');

    _currentAttempts++;

    if (isCorrect) {
      // 정답
      setState(() {
        _selectedAnswer = answer;
        _isAnswered = true;
        _userAnswers[currentQuiz.wordId] = answer;
      });
    } else {
      // 오답
      wrongCount++;
      _shakeScreen();

      if (_currentAttempts >= maxAttempts) {
        // 2번 다 틀림 → 결과 표시
        setState(() {
          _selectedAnswer = answer;
          _isAnswered = true;
          _userAnswers[currentQuiz.wordId] = answer;
        });
      } else {
        // 1번 틀림 → 다시 시도 기회 줌
        setState(() {
          _tempSelected = null;
          // 블록 상태만 리셋 (다시 풀 수 있게)
          _selectedBlocks.clear();
          
          // 섞인 블록 다시 원상복구 (정답 글자들 다시 밑으로 내림)
          final String cleanAnswer = currentQuiz.meaning.trim();
          _shuffledBlocks = cleanAnswer.split('').toList();
          _shuffledBlocks.shuffle();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('틀렸어요! 다시 한번 시도해보세요'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 다음 문제로 이동
  void _handleNext() {
    if (_currentIndex < _quizzes!.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _tempSelected = null;
        _isAnswered = false;
        _currentAttempts = 0;
        
        // [추가] 다음 문제를 위해 블록 상태 초기화
        _shuffledBlocks.clear();
        _selectedBlocks.clear();
        _isBlocksInitialized = false;
      });
    } else {
      _submitQuiz();
    }
  }

  // 최종 제출
  Future<void> _submitQuiz() async {
    try {
      final answers = _quizzes!.map((quiz) {
        return WordQuizCheckReq(
          wordId: quiz.wordId,
          userAnswer: _userAnswers[quiz.wordId] ?? '',
        );
      }).toList();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final result = await _quizService.submitQuiz(widget.stageId, answers);

      if (mounted) {
        Navigator.pop(context);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
            builder: (context) => QuizResultScreen(
                result: result,
                stageId: widget.stageId,
          ),
          ),
          result: true, // 목록 화면 갱신을 위해 true 전달
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
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
      body: AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          final double offset = 
              _shakeController.value > 0 
                  ? 10 * (1 - _shakeController.value) *
                    sin(2 * pi * 2 * _shakeController.value)
                  : 0;
          return Transform.translate(
            offset: Offset(offset, 0),
            child: child,
          );
        },
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(progress),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildQuizContent(currentQuiz),
                ),
              ),
              if (_isAnswered) _buildBottomSheet(currentQuiz),
            ],
          ),
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
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildQuizContent(WordQuizRes quiz) {
    switch (quiz.quizType) {
      case 'WRITING':
        return _buildWriting(quiz); // 여기가 바뀜
      case 'LISTENING':
        return _buildListening(quiz);
      case 'CHOICE':
      default:
        return _buildMultipleChoice(quiz);
    }
  }

  // --- 1. 객관식 UI (기존 동일) ---
  Widget _buildMultipleChoice(WordQuizRes quiz) {
    return Column(
      children: [
        _buildQuestionCard('객관식', '다음 단어의 뜻을 고르세요', quiz),
        const SizedBox(height: 24),
        ...quiz.options.map((option) {
          return _buildOptionButton(option, quiz.meaning);
        }).toList(),
        const SizedBox(height: 16),
        if (!_isAnswered) _buildSubmitButton('정답 확인'),
      ],
    );
  }

  // --- 2. [수정됨] 주관식 UI -> 글자 조각 맞추기 ---
  Widget _buildWriting(WordQuizRes quiz) {
    if (!_isBlocksInitialized) {
      // 1. 정답에서 공백 제거하고 리스트로 만듦
      String cleanAnswer = quiz.meaning.replaceAll(' ', '');
      _shuffledBlocks = cleanAnswer.split('').toList();

      // 2. [핵심] 현재 스테이지의 '다른 단어들'에서 글자를 추출 (오답 풀 만들기)
      final Set<String> distractorPool = {};
      
      // _quizzes 리스트 전체를 돌면서 글자 수집
      if (_quizzes != null) {
        for (var otherQuiz in _quizzes!) {
          // 자기 자신은 제외
          if (otherQuiz.wordId == quiz.wordId) continue;
          
          // 공백 제거한 글자들을 후보군에 등록
          String otherMeaning = otherQuiz.meaning.replaceAll(' ', '');
          for (var char in otherMeaning.split('')) {
            // 정답에 이미 포함된 글자는 굳이 오답으로 안 넣음 (중복 방지)
            if (!cleanAnswer.contains(char)) {
              distractorPool.add(char);
            }
          }
        }
      }

      // 3. 오답 글자 섞어서 2~3개 뽑기
      final List<String> poolList = distractorPool.toList();
      poolList.shuffle(); // 후보군 섞기
      
      final random = Random();
      // 글자 수에 따라 오답 개수 조절 (예: 3글자 이하면 3개 추가, 길면 2개 추가)
      int countToAdd = cleanAnswer.length <= 3 ? 3 : 2;

      for (int i = 0; i < countToAdd; i++) {
        if (poolList.isNotEmpty) {
          _shuffledBlocks.add(poolList.removeAt(0)); // 앞에서 하나씩 꺼내기
        } else {
          // 만약 스테이지에 단어가 1개뿐이라 가져올 게 없으면 랜덤 한글로 대체 (방어 코드)
          final fallback = ['는', '가', '을', '를', '이', '하', '지', '도'];
          _shuffledBlocks.add(fallback[random.nextInt(fallback.length)]);
        }
      }

      // 4. 최종적으로 정답+오답 섞기
      _shuffledBlocks.shuffle();
      _isBlocksInitialized = true;
    }

    return Column(
      children: [
        // 상단 문제 카드 (듣기 버튼 포함)
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
              _buildBadge('순서 맞추기'),
              const SizedBox(height: 16),
              const Text('글자를 순서대로 선택하세요', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              InkWell(
                onTap: () => _playAudio(quiz.audioUrl),
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFFEC407A)]),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF9C27B0).withOpacity(0.3), blurRadius: 20, spreadRadius: 5),
                    ],
                  ),
                  child: const Icon(Icons.volume_up, size: 40, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                quiz.content,
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF9C27B0)),
                textAlign: TextAlign.center,
              ),
              if (quiz.pronunciation != null) ...[
                const SizedBox(height: 8),
                Text('[ ${quiz.pronunciation} ]', style: const TextStyle(fontSize: 16, color: Colors.black54)),
              ]
            ],
          ),
        ),
        
        const SizedBox(height: 32),

        // 2. [정답 입력 칸] (선택된 블록들이 들어가는 곳)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          constraints: const BoxConstraints(minHeight: 80),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isAnswered
                  ? (_selectedBlocks.join() == quiz.meaning.replaceAll(' ', '') ? Colors.green : Colors.red)
                  : const Color(0xFF9C27B0), // 기본 보라색
              width: 2,
            ),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: _selectedBlocks.isEmpty
                ? [const Text('아래 버튼을 눌러 정답을 맞추세요', style: TextStyle(color: Colors.grey, fontSize: 16))]
                : _selectedBlocks.asMap().entries.map((entry) {
                    final index = entry.key;
                    final char = entry.value;
                    return GestureDetector(
                      onTap: _isAnswered ? null : () {
                        // 정답 칸의 블록을 누르면 다시 아래(보기)로 내려감 (취소)
                        setState(() {
                          _selectedBlocks.removeAt(index);
                          _shuffledBlocks.add(char);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E5F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF9C27B0)),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                        ),
                        child: Text(char, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF9C27B0))),
                      ),
                    );
                  }).toList(),
          ),
        ),

        const SizedBox(height: 24),

        // 3. [보기 블록들] (섞여있는 글자들)
        // 이미 제출했으면(정답 확인 후면) 보기 블록을 숨김
        if (!_isAnswered)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: _shuffledBlocks.map((char) {
              return ElevatedButton(
                onPressed: () {
                  // 보기 블록을 누르면 정답 칸으로 올라감
                  setState(() {
                    _shuffledBlocks.remove(char); // 리스트에서 하나 삭제
                    _selectedBlocks.add(char);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Text(char, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              );
            }).toList(),
          ),

        const SizedBox(height: 32),

        // 4. [제출 버튼]
        if (!_isAnswered)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              // 하나라도 선택해야 버튼 활성화
              onPressed: _selectedBlocks.isNotEmpty
                  ? () {
                      final answerString = _selectedBlocks.join(); // 리스트 -> 문자열
                      _handleAnswerSelect(answerString);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                backgroundColor: const Color(0xFF9C27B0),
                disabledBackgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('정답 확인', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
      ],
    );
  }

  // --- 3. 듣기 평가 UI (기존 동일) ---
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

  // --- 공통 위젯들 (기존 동일) ---
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
    final isSelected = _isAnswered ? _selectedAnswer == option : _tempSelected == option;
    final isCorrect = option == correctAnswer;

    Color? bgColor = Colors.white;
    Color borderColor = Colors.grey[300]!;
    double borderWidth = 2;
    Widget? trailing;

    if (_isAnswered) {
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
      isEnabled = _selectedBlocks.isNotEmpty; // 블록이 하나라도 선택되면 활성화
    } else {
      isEnabled = _tempSelected != null;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled
            ? () {
                if (currentQuiz.quizType == 'WRITING') {
                   final answerString = _selectedBlocks.join();
                  _handleAnswerSelect(answerString);
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
                        Navigator.pop(context); 
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