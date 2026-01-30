import 'package:flutter/material.dart';
import 'package:k_lingo_front/models/study/sentence_quiz.dart';
import 'package:k_lingo_front/models/study/sentence_submit_res.dart';
import 'package:k_lingo_front/services/sentence_service.dart';
import 'package:k_lingo_front/widgets/quiz_video_player.dart';

class SentenceQuizScreen extends StatefulWidget {
  final int chapterId;

  const SentenceQuizScreen({super.key, required this.chapterId});

  @override
  State<SentenceQuizScreen> createState() => _SentenceQuizScreenState();
}

class _SentenceQuizScreenState extends State<SentenceQuizScreen> {
  final Color _primaryColor = const Color(0xFFA855F7);
  final Color _lightColor = const Color(0xFFF3E8FF);

  late Future<List<SentenceQuiz>> _quizListFuture;
  List<SentenceQuiz> _quizzes = [];
  int _currentIndex = 0;

  // 상태 관리 변수
  final TextEditingController _blankController = TextEditingController();
  List<String> _selectedWords = [];
  List<String> _availableWords = [];
  
  // ✨ 정답 확인 상태 변수
  bool _isChecked = false; 
  SentenceSubmitRes? _submitResult;

  @override
  void initState() {
    super.initState();
    _quizListFuture = SentenceService().getChapterQuizzes(widget.chapterId);
  }

  void _initQuizState(SentenceQuiz quiz) {
    _blankController.clear();
    _selectedWords.clear();
    _isChecked = false; // 상태 초기화
    _submitResult = null;
    
    if (quiz is ScrambleQuiz) {
      _availableWords = List.from(quiz.shuffledWords);
    }
  }

  // ✨ 상단 경고 메시지 (Overlay 사용)
  void _showTopError(String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10, // 상태바 바로 아래
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    // 2초 뒤에 사라짐
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  void _handleSubmit() async {
    // 1. 이미 확인한 상태라면 아무것도 안 함 (중복 방지)
    if (_isChecked) return;

    final currentQuiz = _quizzes[_currentIndex];
    String userAnswer = "";

    if (currentQuiz is BlankQuiz) {
      userAnswer = _blankController.text.trim();
    } else if (currentQuiz is ScrambleQuiz) {
      userAnswer = _selectedWords.join(" ");
    }

    // 2. 입력값 없으면 상단 경고 띄우기
    if (userAnswer.isEmpty) {
      _showTopError("답을 입력해주세요!"); // ✨ 하단 스낵바 대신 상단 토스트!
      return;
    }

    try {
      final result = await SentenceService().submitQuiz(
        chapterId: widget.chapterId,
        sentenceId: currentQuiz.sentenceId,
        userAnswer: userAnswer,
      );

      // 3. 팝업 대신 화면 상태 변경 (하단 UI가 바뀜)
      setState(() {
        _isChecked = true;
        _submitResult = result;
      });

    } catch (e) {
      _showTopError("제출 실패: $e");
    }
  }

  void _handleNext() {
    if (_currentIndex < _quizzes.length - 1) {
      setState(() {
        _currentIndex++;
        _initQuizState(_quizzes[_currentIndex]);
      });
    } else {
      Navigator.pop(context); // 종료
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<List<SentenceQuiz>>(
          future: _quizListFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: _primaryColor));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("문제가 없습니다."));
            }

            if (_quizzes.isEmpty) {
              _quizzes = snapshot.data!;
              _initQuizState(_quizzes[0]);
            }

            final quiz = _quizzes[_currentIndex];

            return Column(
              children: [
                // 1. 헤더 (진행바)
                _buildHeader(),

                // 2. 문제 영역 (스크롤 가능)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildQuestionCard(quiz),
                        const SizedBox(height: 24),
                        if (quiz is BlankQuiz) _buildBlankQuizUI(quiz)
                        else if (quiz is ScrambleQuiz) _buildScrambleQuizUI(quiz),
                      ],
                    ),
                  ),
                ),

                // 3. ✨ 하단 영역 (Check 버튼 <-> 결과창 교체되는 곳)
                _buildBottomArea(),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- 위젯 빌더 메서드 ---

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (_currentIndex + 1) / _quizzes.length,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _lightColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${_currentIndex + 1} / ${_quizzes.length}",
              style: TextStyle(
                color: _primaryColor, 
                fontWeight: FontWeight.bold,
                fontSize: 12
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(SentenceQuiz quiz) {
    // 1. 영상 정보가 있는지 확인
    bool hasVideo = quiz.youtubeId != null && quiz.youtubeId!.isNotEmpty;

    return Container(
      // 영상일 때는 패딩을 좀 줄여서 화면을 넓게 쓰고, 아닐 땐 기존대로 40
      padding: EdgeInsets.symmetric(vertical: hasVideo ? 20 : 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ✨ 2. 여기가 핵심 변경 포인트!
          if (hasVideo)
            // 영상이 있으면 -> 유튜브 플레이어 표시
            AspectRatio(
              aspectRatio: 16 / 9, // 유튜브 표준 비율
              child: QuizVideoPlayer(
                videoId: quiz.youtubeId!,
                startSeconds: quiz.startTime ?? 0,
                endSeconds: quiz.endTime ?? 10,
              ),
            )
          else
            // 영상이 없으면 -> 기존 스피커 아이콘 표시
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _lightColor,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.volume_up_rounded, color: _primaryColor, size: 28),
            ),

          const SizedBox(height: 20),

          // 3. 문제 텍스트 (영어 뜻)
          Text(
            quiz.question, 
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24, // 영상이랑 같이 볼 때는 폰트 살짝 줄임 (28 -> 24)
              fontWeight: FontWeight.bold,
              color: _primaryColor,
            ),
          ),
          
          const SizedBox(height: 10),
          
          // 4. 힌트
          if (quiz.hint.isNotEmpty)
            Text(
              "[${quiz.hint}]",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
        ],
      ),
    );
  }

  // --- [Type A] 빈칸 퀴즈 UI ---
  Widget _buildBlankQuizUI(BlankQuiz quiz) {
    return Column(
      children: [
        // 문제 문장 보여주기 (빈칸 포함)
        Text(
          quiz.blankSentence, // "화장실이 _______예요?"
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        // 입력 필드
        TextField(
          controller: _blankController,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: _primaryColor, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: "빈칸에 들어갈 말을 입력하세요",
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 20),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: _primaryColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // --- [Type B] 스크램블(어순 맞추기) 퀴즈 UI ---
  Widget _buildScrambleQuizUI(ScrambleQuiz quiz) {
    return Column(
      children: [
        // 1. 선택된 단어들이 들어갈 영역 (정답판)
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 120),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _lightColor, width: 2),
          ),
          child: _selectedWords.isEmpty
              ? Center(
                  child: Text(
                    "아래 단어를 눌러보세요",
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: _selectedWords.map((word) {
                    return ActionChip(
                      label: Text(word),
                      labelStyle: TextStyle(
                        color: _primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      backgroundColor: _lightColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: _lightColor),
                      ),
                      onPressed: () {
                        // 다시 아래로 내리기 (선택 해제)
                        setState(() {
                          _selectedWords.remove(word);
                          _availableWords.add(word);
                        });
                      },
                    );
                  }).toList(),
                ),
        ),
        
        const SizedBox(height: 30),

        // 2. 선택 가능한 단어들 (보기)
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: _availableWords.map((word) {
            return ActionChip(
              label: Text(word),
              labelStyle: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
              backgroundColor: Colors.white,
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.transparent),
              ),
              onPressed: () {
                // 위로 올리기 (선택)
                setState(() {
                  _availableWords.remove(word);
                  _selectedWords.add(word);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBottomArea() {
    // A. 아직 문제 푸는 중일 때 (기본 Check 버튼)
    if (!_isChecked) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: _lightColor,
              foregroundColor: _primaryColor,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text("Check", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      );
    }

    // B. 정답 확인 후 (결과창 + Next 버튼)
    final bool isCorrect = _submitResult?.isCorrect ?? false;
    final Color statusColor = isCorrect ? Colors.green : Colors.red;
    final Color bgColor = isCorrect ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2); // 연한 초록 / 연한 빨강
    final String title = isCorrect ? "Great Job!" : "Incorrect";
    final IconData icon = isCorrect ? Icons.check_circle : Icons.cancel;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20), // 위쪽 패딩 좀 더 줌
      decoration: BoxDecoration(
        color: bgColor, 
        // 위쪽만 둥글게 깎지 않고 그냥 네모나게 채우거나, 살짝만 줌
        border: Border(top: BorderSide(color: statusColor.withOpacity(0.1), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 결과 제목 (아이콘 + 텍스트)
          Row(
            children: [
              Icon(icon, color: statusColor, size: 30),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),

          // 2. 정답 보여주기
          if (_submitResult != null)
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Text(
                "Answer: ${_submitResult!.correctAnswer}",
                style: TextStyle(color: statusColor, fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
            
          const SizedBox(height: 20),

          // 3. Next 버튼 (Check 버튼 위치와 동일하게 배치)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _handleNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: statusColor, // 버튼 색상 (초록/빨강)
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Continue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}