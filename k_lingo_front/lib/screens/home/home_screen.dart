import 'package:flutter/material.dart';
import '../../config/routes.dart';
import '../../models/member/member_progress.dart';
import '../../services/member_service.dart';
import '../../models/quest/quest.dart';
import '../../services/quest_service.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:k_lingo_front/screens/study/sentence_chapter_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- 서비스 및 상태 변수 ---
  final MemberService _memberService = MemberService();
  final QuestService _questService = QuestService();

  MemberProgress? _progress; // 내 정보 (XP, 레벨, 오늘의 팁)
  List<Quest> _quests = []; // 퀘스트 목록

  bool _isLoading = true; // 로딩 상태
  bool showProgress = true; // true: Progress 탭, false: Quest 탭

  @override
  void initState() {
    super.initState();
    _fetchProgress();
    _fetchQuests();
  }

  // --- 데이터 로딩 함수 ---
  Future<void> _fetchProgress() async {
    try {
      final data = await _memberService.getMyProgress();
      if (mounted) {
        setState(() {
          _progress = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ 홈 데이터 로딩 실패: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchQuests() async {
    try {
      final quests = await _questService.getTodayQuests();
      if (mounted) {
        setState(() {
          _quests = quests;
        });
      }
    } catch (e) {
      print('❌ 퀘스트 로딩 실패: $e');
    }
  }

  // --- 보상 받기 로직 ---
  Future<void> _handleClaimReward(int questId) async {
    try {
      final reward = await _questService.claimReward(questId);

      int remainingXp = reward.requiredXp - reward.currentXp;
      if (remainingXp < 0) remainingXp = 0;

      if (mounted) {
        // 상단 알림 띄우기
        _showTopNotification(
            context, '${reward.rewardXp} XP 획득! (다음 레벨까지 $remainingXp XP)');
        
        // 데이터 갱신 (XP바 업데이트 & 퀘스트 상태 업데이트)
        await _fetchProgress();
        await _fetchQuests();
      }
    } catch (e) {
      if (mounted) {
        _showTopNotification(context, '⚠️ 보상 수령에 실패했습니다.');
      }
    }
  }
  
  void _handleSectionTap(String type) async {
    // 1. 단어장 (TOPIC)
    if (type == 'TOPIC') {
      final result = await Navigator.pushNamed(context, Routes.categories);
      if (result == true && mounted) {
        _fetchProgress();
        _fetchQuests();
      }
    } 
    // 2. 문장 공부 (SENTENCE)
    else if (type == 'SENTENCE') {
      final result = await Navigator.pushNamed(context, Routes.sentenceChapters);
      if (result == true && mounted) {
        _fetchProgress();
        _fetchQuests();
      }
    }
    // 3. K-Drama (✨ 추가)
    else if (type == 'KDRAMA') {
      final result = await Navigator.pushNamed(context, Routes.dramaChapters);
      if (result == true && mounted) {
        _fetchProgress();
        _fetchQuests();
      }
    }
    // 4. K-Pop (✨ 추가)
    else if (type == 'KPOP') {
      final result = await Navigator.pushNamed(context, Routes.kpopChapters);
      if (result == true && mounted) {
        _fetchProgress();
        _fetchQuests();
      }
    }
    // 5. 그 외 (예외 처리)
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('준비 중인 콘텐츠입니다! 🚧')),
      );
    }
  }

  Map<String, dynamic> _getSectionStyle(String type) {
    switch (type) {
      case 'TOPIC': // Topics (파란색 + 책 아이콘)
        return {
          'colors': [
            const Color(0xFF42A5F5), // 밝은 파랑
            const Color(0xFF1E88E5), // 진한 파랑
          ],
          'icon': Icons.menu_book_rounded, // 펼친 책 아이콘
        };
        
      case 'SENTENCE': // Sentences (초록색 + 필기 아이콘)
        return {
          'colors': [
            const Color(0xFF26A69A), // 밝은 청록
            const Color(0xFF00897B), // 진한 청록
          ],
          'icon': Icons.edit_note_rounded, // 노트 필기 아이콘
        };
        
      case 'KDRAMA': // K-Drama (보라색 + 슬레이트 아이콘)
        return {
          'colors': [
            const Color(0xFFAB47BC), // 밝은 보라
            const Color(0xFF8E24AA), // 진한 보라
          ],
          'icon': Icons.movie_rounded, // 영화 슬레이트 아이콘
        };
        
      case 'KPOP': // K-Pop (붉은색 + 음표 아이콘)
        return {
          'colors': [
            const Color(0xFFEF5350), // 밝은 빨강
            const Color(0xFFC62828), // 진한 빨강
          ],
          'icon': Icons.music_note_rounded, // 음표 아이콘
        };
        
      default: // 예외 처리 (회색)
        return {
          'colors': [Colors.grey.shade400, Colors.grey.shade600],
          'icon': Icons.help_outline_rounded,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF9FAFB),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFA855F7))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      extendBody: true, // 바텀 네비게이션바 뒤로 배경 확장
      
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            await _fetchProgress();
            await _fetchQuests();
          },
          color: const Color(0xFFA855F7),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100), // 네비게이션바 공간 확보
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. 헤더 (메뉴, 알림)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeaderIcon(Icons.menu_rounded),
                      _buildHeaderIcon(Icons.notifications_outlined),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // 2. 메인 카드 (그라데이션 배경)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFF3E5F5), Color(0xFFFCE4EC)],
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFA855F7).withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // [수정] 5:5 비율 탭 버튼
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildTopTabSection(),
                        ),
                        
                        // 내용물 (Progress / Quest)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              minHeight: 330,
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                              child: showProgress
                                  ? _buildProgressContent()
                                  : _buildQuestContent(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 3. Class in progress
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. 섹션 타이틀
                      const Text(
                        'Explore Categories', // 제목 변경 (원하는 대로 수정 가능)
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // 2. 2열 그리드 뷰 (여기가 핵심!)
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.3,
                        
                        // 서버 데이터를 map으로 돌려서 카드 생성
                        children: _progress?.sections.map((section) {
                          final style = _getSectionStyle(section.type);

                          return _buildGridCard(
                            title: section.title,
                            subtitle: section.description,
                            progress: section.progress / 100.0, // % 변환
                            colors: style['colors'],
                            icon: style['icon'],
                            onTap: () => _handleSectionTap(section.type),
                          );
                        }).toList() ?? [], // 데이터 없으면 빈 리스트
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UI 구성 요소 메서드들 ---

  Widget _buildHeaderIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(icon, size: 24, color: Colors.grey[800]),
    );
  }

  // [핵심 수정] 5:5 비율 탭 버튼
  Widget _buildTopTabSection() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => showProgress = true),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: showProgress ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: showProgress
                    ? [
                        BoxShadow(
                            color: const Color(0xFF9F7AEA).withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  "Progress",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: showProgress ? const Color(0xFF9F7AEA) : const Color(0xFFA0AEC0),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => showProgress = false);
              _fetchQuests(); // 퀘스트 탭 누를 때 데이터 갱신
            },
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: !showProgress ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: !showProgress
                    ? [
                        BoxShadow(
                            color: const Color(0xFF9F7AEA).withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  "Today's Quest",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: !showProgress ? const Color(0xFF9F7AEA) : const Color(0xFFA0AEC0),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- Progress 탭 내용 ---
  Widget _buildProgressContent() {
    final nickname = _progress?.nickname ?? 'Guest';
    final level = _progress?.level ?? 1;
    final rankTitle = _progress?.rankTitle ?? 'New Student';
    final streakDays = _progress?.streakDays ?? 0;
    final currentXp = _progress?.currentXp ?? 0;
    final requiredXp = _progress?.requiredXp ?? 100;
    final remainingXp = _progress?.remainingXp ?? 0;
    final xpPercent = (_progress?.xpPercentage ?? 0) / 100.0;

    return Column(
      key: const ValueKey('Progress'),
      children: [
        // 레벨 & 스트릭 정보
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE9D5FF).withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Text('Level $level',
                      style: const TextStyle(
                          color: Color(0xFF7C3AED),
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(width: 12),
                  Text(rankTitle,
                      style: const TextStyle(
                          color: Color(0xFF7C3AED),
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFED7AA).withOpacity(0.6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department,
                      color: Color(0xFFF97316), size: 20),
                  const SizedBox(width: 6),
                  Text('$streakDays Day',
                      style: const TextStyle(
                          color: Color(0xFFF97316),
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // XP 카드
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  text: 'Welcome back, ',
                  style: const TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
                  children: [
                    TextSpan(
                        text: nickname,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF8B5CF6))),
                    const TextSpan(text: '!'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text('Keep learning to level up! 💪',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8B5CF6))),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: xpPercent,
                  minHeight: 12,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                ),
              ),
              const SizedBox(height: 7),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$currentXp / $requiredXp XP',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF6B7280))),
                  Text('$remainingXp XP to Level ${level + 1}',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9CA3AF))),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 13),

        // [핵심] 오늘의 팁 (슬림 카드)
        _buildDailyTip(),
      ],
    );
  }

  // --- Quest 탭 내용 ---
  Widget _buildQuestContent() {
    if (_quests.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text("Loading quests...", style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    int completedCount = _quests.where((q) => q.isCompleted).length;
    int totalCount = _quests.length;

    return Column(
      key: const ValueKey('Quest'),
      children: [
        ..._quests.map((quest) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildQuestItemCard(quest),
        )).toList(),

        const SizedBox(height: 1),

        // Daily Progress 요약
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daily Progress',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$completedCount / $totalCount Completed',
                style: const TextStyle(
                  color: Color(0xFFA855F7),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDailyTip() {
    // 1. 서버 데이터가 있으면 그거 쓰고, 없으면 임시 데이터 사용
    // (API 연동 전에도 UI 확인 가능하게 수정)
    final tipIcon = _progress?.dailyTip?.icon ?? "💡";
    final tipTitle = _progress?.dailyTip?.title ?? "Did you know?";
    final tipTag = _progress?.dailyTip?.tag ?? "Culture";
    final tipContent = _progress?.dailyTip?.content ?? 
        "한국에서는 밥그릇을 식탁에 두고 먹는 것이 예절입니다.";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9F7AEA).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // 아이콘
          Container(
            width: 38, height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF4E6),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                tipIcon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 텍스트
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      tipTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9F7AEA),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7FAFC),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tipTag,
                        style: const TextStyle(fontSize: 10, color: Color(0xFF718096)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  tipContent,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4A4A4A),
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 퀘스트 카드
  Widget _buildQuestItemCard(Quest quest) {
    bool isCompleted = quest.isCompleted;
    bool isClaimed = quest.rewardClaimed;

    Color cardColor = (isCompleted && !isClaimed)
        ? const Color(0xFFF3E8FF)
        : Colors.white.withOpacity(0.8);

    return GestureDetector(
      onTap: (isCompleted && !isClaimed)
          ? () => _handleClaimReward(quest.id)
          : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildQuestStatusIcon(quest),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quest.description,
                    style: TextStyle(
                      color: isClaimed ? const Color(0xFFBDBDBD) : const Color(0xFF1E293B),
                      fontSize: 15,
                      fontWeight: isCompleted && !isClaimed ? FontWeight.bold : FontWeight.normal,
                      decoration: isClaimed ? TextDecoration.lineThrough : TextDecoration.none,
                      decorationColor: const Color(0xFFBDBDBD),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!isCompleted)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${quest.currentCount} / ${quest.targetCount}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                      ),
                    ),
                ],
              ),
            ),
            if (isCompleted && !isClaimed)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFA855F7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Get!',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              )
            else
              Text('+${quest.rewardXp} XP',
                  style: TextStyle(
                    color: isClaimed ? const Color(0xFFBDBDBD) : const Color(0xFF10B981),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestStatusIcon(Quest quest) {
    bool isCompleted = quest.isCompleted;
    bool isClaimed = quest.rewardClaimed;

    if (isClaimed) {
      return Container(
        width: 36, height: 36,
        decoration: const BoxDecoration(
          color: Color(0xFF10B981),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 20),
      );
    } else if (isCompleted) {
      return Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFA855F7), width: 2),
        ),
        child: const Icon(Icons.redeem, color: Color(0xFFA855F7), size: 20),
      );
    } else {
      double progress = quest.targetCount > 0 ? quest.currentCount / quest.targetCount : 0.0;
      return SizedBox(
        width: 36, height: 36,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: 1.0, strokeWidth: 3, valueColor: AlwaysStoppedAnimation(Colors.grey[200]!)
            ),
            CircularProgressIndicator(
              value: progress, strokeWidth: 3, backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation(Color(0xFFA855F7)), strokeCap: StrokeCap.round,
            ),
          ],
        ),
      );
    }
  }

  // GridView에서 쓰일 카드 위젯
Widget _buildGridCard({
    required String title,
    required String subtitle,
    required double progress,
    required List<Color> colors,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                CircularPercentIndicator(
                  radius: 20.0,
                  lineWidth: 4.0,
                  percent: progress, // 0.0 ~ 1.0
                  center: Text(
                    "${(progress * 100).toInt()}%",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: colors[1],
                    ),
                  ),
                  progressColor: colors[1],
                  backgroundColor: colors[0].withOpacity(0.1),
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9CA3AF),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showTopNotification(BuildContext context, String message) {
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20, right: 20,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: -100.0, end: 0.0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            builder: (context, value, child) => Transform.translate(offset: Offset(0, value), child: child),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Color(0xFFF3E8FF), shape: BoxShape.circle),
                    child: const Icon(Icons.celebration, color: Color(0xFFA855F7), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(message, style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 14))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () => overlayEntry.remove());
  }
}