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
  static const Color kBackground = Color(0xFFF3E8FF); 
  static const Color kAccentPurple = Color(0xFF9F7AEA); 
  static const Color kAccentDeep = Color(0xFF805AD5);   
  static const Color kLightLavender = Color(0xFFE9D8FD);
  static const Color kTextBlack = Color(0xFF4A4A4A);
  static const Color kTextGrey = Color(0xFF8D8D8D);

  final WordQuizService _quizService = WordQuizService();
  final AudioPlayer _audioPlayer = AudioPlayer();

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
          // 블록 상태 리셋
          _selectedBlocks.clear();
          
          // 블록 다시 섞기
          _shuffledBlocks.shuffle();
        });
        
        _showErrorNotification(context, 'Incorrect! Try again.'); 
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
        Navigator.pop(context, true); 
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
        Navigator.pop(context, true);
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
        backgroundColor: const Color(0xFFF3E8FF),
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
                child: Padding(
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
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // 1. 닫기 버튼
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () => Navigator.pop(context, true),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(Icons.close_rounded, color: Colors.black54, size: 24),
                ),
              ),
            ),
            
            // 2. 게이지 바
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 32),
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // 원래 계산된 너비
                    final double calculatedWidth = constraints.maxWidth * progress;
                    
                    // [핵심 수정] 
                    // 계산된 너비가 60보다 작으면 강제로 60으로 늘림 (글자 공간 확보)
                    // 아니면 원래대로 표시
                    final double displayWidth = calculatedWidth < 60 ? 60 : calculatedWidth;

                    return Stack(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                          width: displayWidth,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            // [변경] 그라데이션 대신 '단색 블루베리'가 더 깔끔하고 요즘 느낌입니다.
                            color: const Color(0xFF9F7AEA), 
                            borderRadius: BorderRadius.circular(20),
                            // 그림자는 아주 약하게 넣거나 뺍니다.
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF9F7AEA).withOpacity(0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0), // 여백 살짝 늘림
                            child: Text(
                              '${_currentIndex + 1} / ${_quizzes!.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
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

  // --- 객관식 UI ---
  Widget _buildMultipleChoice(WordQuizRes quiz) {
    // 여기에 SingleChildScrollView 추가
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildQuestionCard('객관식', '다음 단어의 뜻을 고르세요', quiz),
          const SizedBox(height: 24),
          ...quiz.options.map((option) {
            return _buildOptionButton(option, quiz.meaning);
          }).toList(),
          const SizedBox(height: 16),
          if (!_isAnswered) _buildSubmitButton('정답 확인'),
        ],
      ),
    );
  }

  Widget _buildWriting(WordQuizRes quiz) {
    // 1. 블록 초기화 로직 (기존 유지)
    if (!_isBlocksInitialized) {
      String cleanAnswer = quiz.meaning.replaceAll(' ', '');
      _shuffledBlocks = cleanAnswer.split('').toList();
      
      final Set<String> distractorPool = {};
      if (_quizzes != null) {
        for (var otherQuiz in _quizzes!) {
          if (otherQuiz.wordId == quiz.wordId) continue;
          String otherMeaning = otherQuiz.meaning.replaceAll(' ', '');
          for (var char in otherMeaning.split('')) {
            if (!cleanAnswer.contains(char)) {
              distractorPool.add(char);
            }
          }
        }
      }

      final List<String> poolList = distractorPool.toList();
      poolList.shuffle();
      final random = Random();
      int countToAdd = cleanAnswer.length <= 3 ? 3 : 2;

      for (int i = 0; i < countToAdd; i++) {
        if (poolList.isNotEmpty) {
          _shuffledBlocks.add(poolList.removeAt(0));
        } else {
          final fallback = ['는', '가', '을', '를', '이', '하', '지', '도'];
          _shuffledBlocks.add(fallback[random.nextInt(fallback.length)]);
        }
      }
      _shuffledBlocks.shuffle();
      _isBlocksInitialized = true;
    }

    // 현재 정답 칸에 들어갈 글자 조합 (String 리스트 조인)
    final currentAnswerString = _selectedBlocks.join();

    return Column(
      children: [
        // --- 1. 상단 문제 카드 (블루베리 디자인 적용) ---
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: kAccentPurple.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // 듣기 버튼
              InkWell(
                onTap: () => _playAudio(quiz.audioUrl),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: kLightLavender,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.volume_up_rounded, size: 28, color: kAccentDeep),
                ),
              ),
              const SizedBox(height: 16),
              
              // 메인 단어
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  quiz.content,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: kAccentDeep,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              // 발음
              if (quiz.pronunciation != null) ...[
                const SizedBox(height: 8),
                Text('[${quiz.pronunciation}]',
                    style: const TextStyle(fontSize: 16, color: kTextGrey, fontWeight: FontWeight.w500)),
              ]
            ],
          ),
        ),

        const SizedBox(height: 24),

        // --- 2. 정답 칸 (로직: _selectedBlocks 사용) ---
        Container(
          width: double.infinity,
          height: 160,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isAnswered
                  ? (currentAnswerString == quiz.meaning.replaceAll(' ', '')
                      ? const Color(0xFF48BB78) // 정답: 파스텔 초록
                      : const Color(0xFFF56565)) // 오답: 파스텔 빨강
                  : kLightLavender, // 평소: 연보라
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: kAccentPurple.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: _selectedBlocks.isEmpty
                  ? [
                      const Text(
                        '아래 단어를 눌러보세요',
                        style: TextStyle(color: Color(0xFFCBD5E0), fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ]
                  // [로직 유지] _selectedBlocks 사용
                  : _selectedBlocks.asMap().entries.map((entry) {
                      final index = entry.key;
                      final char = entry.value;
                      return GestureDetector(
                        onTap: _isAnswered
                            ? null
                            : () {
                                setState(() {
                                  _selectedBlocks.removeAt(index);
                                });
                              },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: kAccentPurple, // 선택된 건 진한 보라
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: kAccentDeep.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Text(
                            char,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
            ),
          ),
        ),

        // --- 3. 보기 블록 (로직: 중복 글자 계산 방식 + 디자인: 마카롱) ---
        Expanded(
          child: Center(
            child: _isAnswered
                ? const SizedBox()
                : SingleChildScrollView(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: List.generate(_shuffledBlocks.length, (index) {
                        final char = _shuffledBlocks[index];

                        // [핵심 로직 복구] 중복 글자 처리 로직 (이게 있어야 위치가 고정됨)
                        int inAnswerCount = _selectedBlocks.where((e) => e == char).length;
                        int priorInOptionsCount = _shuffledBlocks.sublist(0, index).where((e) => e == char).length;
                        bool isSelected = priorInOptionsCount < inAnswerCount;

                        return Visibility(
                          visible: !isSelected,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: ElevatedButton(
                            onPressed: isSelected
                                ? null
                                : () {
                                    setState(() {
                                      _selectedBlocks.add(char);
                                    });
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white, // 배경 흰색
                              foregroundColor: kTextBlack,   // 글자 먹색
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                              ),
                            ).copyWith(
                              overlayColor: MaterialStateProperty.all(kLightLavender.withOpacity(0.5)),
                            ),
                            child: Text(char,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        );
                      }),
                    ),
                  ),
          ),
        ),

        // --- 4. Check 버튼 ---
        if (!_isAnswered)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // [로직 유지] _selectedBlocks 사용
                onPressed: _selectedBlocks.isNotEmpty
                    ? () {
                        final answerString = _selectedBlocks.join();
                        _handleAnswerSelect(answerString);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: kAccentPurple,
                  disabledBackgroundColor: kLightLavender,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  shadowColor: kAccentDeep,
                  elevation: 4,
                ),
                child: const Text('Check',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
      ],
    );
  }

  // --- 듣기 평가 UI ---
  Widget _buildListening(WordQuizRes quiz) {
    // 여기에 SingleChildScrollView 추가
    return SingleChildScrollView(
      child: Column(
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
                const Text('들려주는 단어의 뜻은?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                InkWell(
                  onTap: () => _playAudio(quiz.audioUrl),
                  child: Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      // [변경] 은은한 그라데이션 (연보라 -> 조금 진한 보라)
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFD6BCFA), Color(0xFF9F7AEA)],
                      ),
                      shape: BoxShape.circle,
                      // 그림자를 부드럽게 퍼뜨려서 '몽글몽글'하게
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9F7AEA).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.volume_up_rounded, size: 40, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('🔊 눌러서 듣기',
                    style: TextStyle(fontSize: 14, color: Colors.black54)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ...quiz.options
              .map((option) => _buildOptionButton(option, quiz.meaning))
              .toList(),
          const SizedBox(height: 16),
          if (!_isAnswered) _buildSubmitButton('정답 확인'),
        ],
      ),
    );
  }

  // --- 공통 위젯들 (기존 동일) ---
  Widget _buildQuestionCard(String badge, String title, WordQuizRes quiz) {
    // 글자 크기 계산 로직 (기존 동일)
    double fontSize;
    if (quiz.content.length > 30) {
      fontSize = 22;
    } else if (quiz.content.length > 15) {
      fontSize = 28;
    } else {
      fontSize = 36;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // 모서리 둥글게 (24)
        // [변경] 그림자를 아주 연한 보라색으로 변경
        boxShadow: [
          BoxShadow(
            color: kAccentPurple.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // [변경] 뱃지 디자인: 그라데이션 빼고 파스텔 톤으로
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: kLightLavender, // 연한 라벤더 배경
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badge, 
              style: const TextStyle(
                fontSize: 13, 
                fontWeight: FontWeight.bold, 
                color: kAccentDeep // 글자는 진한 보라
              )
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 질문 제목 (연한 회색)
          Text(title,
              style: const TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.w600,
                color: kTextGrey, 
              )),
              
          const SizedBox(height: 24),
          
          // 메인 단어 (보라색 포인트)
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              quiz.content,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: kAccentDeep, // [변경] 진한 보라색
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
          ),
          
          // 발음 (우리가 아까 수정한 로직 포함)
          if (quiz.pronunciation != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '[${quiz.pronunciation}]',
                  style: const TextStyle(
                    fontSize: 16,
                    color: kTextGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
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

    Color bgColor = Colors.white; // 기본은 깨끗한 흰색
    Color borderColor = Colors.transparent;
    Color textColor = const Color(0xFF4A4A4A); // 기본 글자색 (먹색)

    if (_isAnswered) {
      if (isCorrect) {
        bgColor = const Color(0xFFC6F6D5); // 파스텔 민트 (정답)
        textColor = const Color(0xFF2F855A);
      } else if (isSelected) {
        bgColor = const Color(0xFFFED7D7); // 파스텔 레드 (오답)
        textColor = const Color(0xFFC53030);
      }
    } else {
      if (isSelected) {
        // [변경] 선택 시: 사진 속 'Progress' 버튼 같은 연한 보라색 배경
        bgColor = const Color(0xFFE9D8FD); 
        borderColor = const Color(0xFF9F7AEA); // 블루베리색 테두리
        textColor = const Color(0xFF6B46C1);   // 글자도 진한 보라
      } else {
        // 선택 안 함: 그냥 흰색 박스 (그림자만 살짝)
        bgColor = Colors.white;
        textColor = const Color(0xFF4A4A4A);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: _isAnswered ? null : () => setState(() => _tempSelected = option),
        borderRadius: BorderRadius.circular(20), // [변경] 더 둥글게 (20)
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: borderColor, 
              width: isSelected ? 2 : 0
            ),
            // 선택 안 된 애들만 부드러운 그림자 (카드 느낌)
            boxShadow: isSelected || _isAnswered ? [] : [
              BoxShadow(
                color: const Color(0xFF9F7AEA).withOpacity(0.05), // 그림자도 보라빛 살짝
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(String text) {
    bool isEnabled = false;
    final currentQuiz = _quizzes![_currentIndex];

    // 1. 활성화 여부 체크
    if (currentQuiz.quizType == 'WRITING') {
      isEnabled = _selectedBlocks.isNotEmpty; // 블록 퀴즈일 때
    } else {
      isEnabled = _tempSelected != null;      // 객관식일 때
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        // [수정] 여기가 비어있었습니다! 로직을 다시 채워넣음
        onPressed: isEnabled
            ? () {
                if (currentQuiz.quizType == 'WRITING') {
                  // 블록 퀴즈 정답 제출
                  final answerString = _selectedBlocks.join();
                  _handleAnswerSelect(answerString);
                } else {
                  // 객관식 정답 제출
                  _handleAnswerSelect(_tempSelected!);
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          backgroundColor: const Color(0xFF9F7AEA), // 블루베리 퍼플
          disabledBackgroundColor: const Color(0xFFD6BCFA), // 연한 보라
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          shadowColor: const Color(0xFF805AD5),
          elevation: 4,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // --- O/X 결과 바텀시트 ---
  Widget _buildBottomSheet(WordQuizRes quiz) {
    // 공백 제거 후 비교 로직
    final bool isCorrect = _selectedAnswer!.replaceAll(' ', '') == quiz.meaning.replaceAll(' ', '');

    // 색상 테마 설정 (파스텔 톤)
    final Color iconColor = isCorrect ? const Color(0xFF38A169) : const Color(0xFFE53E3E); // 초록 / 빨강
    final Color bgColor = isCorrect ? const Color(0xFFF0FFF4) : const Color(0xFFFFF5F5); // 연한 초록 / 연한 빨강 배경
    final String msg = isCorrect ? '정답입니다!' : '오답입니다';
    final IconData icon = isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40), // 하단 여백 넉넉히
      decoration: BoxDecoration(
        color: Colors.white,
        // 위쪽 모서리만 둥글게
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 결과 메시지 행
          Row(
            children: [
              // 아이콘 뒤에 연한 배경 원 추가
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor, 
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg,
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold, 
                      color: iconColor
                    ),
                  ),
                  // 오답일 때 정답 보여주기
                  if (!isCorrect) ...[
                    const SizedBox(height: 4),
                    Text(
                      '정답: ${quiz.meaning}',
                      style: const TextStyle(
                        fontSize: 15, 
                        color: kTextGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // 2. 다음 버튼 (정답확인 버튼과 스타일 통일)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleNext,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                backgroundColor: kAccentPurple, // 블루베리 퍼플
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                shadowColor: kAccentDeep,
                elevation: 4,
              ),
              child: Text(
                _currentIndex < _quizzes!.length - 1 ? '다음 문제' : '결과 보기',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  // 색상 테마 (QuizScreen과 통일)
  static const Color kBackground = Color(0xFFF3E8FF);
  static const Color kAccentPurple = Color(0xFF9F7AEA);
  static const Color kAccentDeep = Color(0xFF805AD5);
  static const Color kLightLavender = Color(0xFFE9D8FD);
  static const Color kTextBlack = Color(0xFF4A4A4A);
  static const Color kTextGrey = Color(0xFF8D8D8D);

  const QuizResultScreen({
    Key? key,
    required this.result,
    required this.stageId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isPassed = result.isPassed;
    // 통과 여부에 따른 멘트와 아이콘 설정
    final String title = isPassed ? 'Perfect!' : 'Keep Going';
    final String subTitle = isPassed 
        ? '정말 대단해요! 실력이 늘고 있어요 🎉' 
        : '조금만 더 노력하면 할 수 있어요 💪';
    final IconData mainIcon = isPassed ? Icons.emoji_events_rounded : Icons.school_rounded;
    final Color iconColor = isPassed ? const Color(0xFFFFD700) : kAccentPurple; // 골드 vs 보라

    return Scaffold(
      backgroundColor: kBackground, // 연한 라벤더 배경
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. 결과 카드
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32), // 둥글둥글하게
                    boxShadow: [
                      BoxShadow(
                        color: kAccentPurple.withOpacity(0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // 아이콘 (배경 원 + 아이콘)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isPassed ? const Color(0xFFFFF9C4) : kLightLavender, // 연한 노랑 vs 연한 보라
                          shape: BoxShape.circle,
                        ),
                        child: Icon(mainIcon, size: 64, color: iconColor),
                      ),
                      
                      const SizedBox(height: 32),

                      // 타이틀 (통과!)
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: kTextBlack,
                          letterSpacing: -0.5,
                        ),
                      ),
                      
                      const SizedBox(height: 8),

                      // 서브 메시지
                      Text(
                        subTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: kTextGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // 점수 표시 (가장 중요!)
                      // 핑크 박스 없애고, 거대한 텍스트로 강조
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${result.correctCount}',
                            style: const TextStyle(
                              fontSize: 80, // 엄청 크게!
                              fontWeight: FontWeight.w900,
                              color: kAccentDeep, // 진한 보라색
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '/ ${result.totalCount}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFCBD5E0), // 연한 회색
                            ),
                          ),
                        ],
                      ),
                      
                      // 점수 아래 작은 설명
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: kBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Correct Answers',
                          style: TextStyle(fontSize: 12, color: kAccentPurple, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

              // 2. 하단 버튼 (목록으로)
                // [수정] SizedBox -> Container 로 변경 (SizedBox는 constraints 속성이 없음)
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      backgroundColor: kAccentPurple, // 블루베리 퍼플
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: kAccentDeep.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      '목록으로 돌아가기',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 상단 에러 알림 함수
  void _showErrorNotification(BuildContext context, String message) {
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        // 상태바(Top Notch) 바로 아래 위치
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: -100.0, end: 0.0), // 위에서 아래로 슬라이드
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, value),
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 빨간색 에러 아이콘 배경
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.red, size: 20),
                  ),
                  const SizedBox(width: 12),
                  // 메시지 텍스트
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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

    // 화면에 표시
    Overlay.of(context).insert(overlayEntry);

    // 2초 뒤에 사라짐 (오답은 빨리 사라지는 게 좋음)
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }