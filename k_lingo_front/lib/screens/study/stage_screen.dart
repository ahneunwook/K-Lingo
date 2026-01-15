import 'package:flutter/material.dart';
import 'package:k_lingo_front/services/stage_service.dart'; 
import 'package:k_lingo_front/models/study/stage.dart'; 
import 'package:k_lingo_front/models/study/chapter.dart';
import 'package:k_lingo_front/config/routes.dart';

class StageScreen extends StatefulWidget {
  final Chapter chapter;

  const StageScreen({Key? key, required this.chapter}) : super(key: key);

  @override
  State<StageScreen> createState() => _StageScreenState();
}

class _StageScreenState extends State<StageScreen> {
  final StageService _stageService = StageService();
  
  List<Stage>? _stages;
  bool _isLoading = true;
  String? _error;
  bool _shouldReload = false;

  @override
  void initState() {
    super.initState();
    _loadStages();
  }

  Future<void> _loadStages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stages = await _stageService.getStages(widget.chapter.id);
      setState(() {
        _stages = stages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.pop(context, _shouldReload),
      ),
      title: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF3E5F5), Color(0xFFFCE4EC)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                widget.chapter.icon ?? '📚',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chapter.nameKr,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.chapter.nameEn, // nameEn 유지
                  style: const TextStyle(
                    color: Color(0xFF9C27B0),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('오류: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStages,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_stages == null || _stages!.isEmpty) {
      return const Center(child: Text('등록된 스테이지가 없습니다.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _stages!.length,
      itemBuilder: (context, index) {
        final stage = _stages![index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildStageCard(stage),
        );
      },
    );
  }

  Widget _buildStageCard(Stage stage) { // WordStage → Stage
    bool isLocked = stage.isLocked ?? false; 
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isLocked ? null : () async {  
            final result = await Navigator.pushNamed( 
              context,
              Routes.quiz,
              arguments: stage.id,
            );
        
            if (result == true && mounted) { 
              _loadStages();
              _shouldReload = true;
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildStageIcon(stage),
                const SizedBox(width: 16),
                Expanded(child: _buildStageContent(stage)),
                _buildStageTrailing(stage),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 아래 UI 관련 메서드들은 그대로 둡니다 (수정 필요 없음) ---
  Widget _buildStageIcon(Stage stage) {
    bool isLocked = stage.isLocked ?? false;
    bool isCleared = stage.isCleared ?? false;
    
    // 점수에 따른 링 색상 및 채움 정도
    double progress = isLocked ? 0 : ((stage.bestScore ?? 0) / 10.0);
    Color activeColor = isCleared ? const Color(0xFF4CAF50) : const Color(0xFF9C27B0);

    return SizedBox(
      width: 54, height: 54,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. 회색 트랙 (배경 링)
          SizedBox(
            width: 54, height: 54,
            child: CircularProgressIndicator(
              value: 1.0, // 전체 원
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation(Colors.grey[200]),
            ),
          ),
          // 2. 진행률 표시 링 (점수만큼 차오름)
          if (!isLocked)
            SizedBox(
              width: 54, height: 54,
              child: CircularProgressIndicator(
                value: isCleared ? 1.0 : progress, // 클리어면 꽉 채움
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation(activeColor),
                strokeCap: StrokeCap.round, // 끝부분 둥글게
              ),
            ),
          // 3. 가운데 아이콘 또는 숫자
          isLocked
              ? const Icon(Icons.lock, color: Colors.grey, size: 20)
              : Text(
                  '${stage.stageOrder}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: activeColor, // 글자색도 링 색깔과 맞춤
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildStageContent(Stage stage) {
    bool isLocked = stage.isLocked ?? false;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STAGE ${stage.stageOrder ?? 0}',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF9C27B0),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          stage.title ?? 'No Title',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        if (!isLocked && (stage.bestScore ?? 0) > 0)
          _buildScoreBadge(stage.bestScore ?? 0)
        else if (isLocked)
          const Text(
            '이전 스테이지를 완료하세요',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black38,
            ),
          ),
      ],
    );
  }

  Widget _buildScoreBadge(int score) {
    Color scoreColor;
    if (score >= 8) {
      scoreColor = const Color(0xFF4CAF50); 
    } else if (score >= 5) {
      scoreColor = const Color(0xFFFF9800); 
    } else {
      scoreColor = Colors.grey;
    }

    return Row(
      children: [
        Icon(Icons.emoji_events, size: 16, color: scoreColor),
        const SizedBox(width: 4),
        Text(
          '$score/10',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: scoreColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStageTrailing(Stage stage) {
    if (stage.isLocked ?? false) {
      return const Icon(Icons.lock, color: Colors.black12, size: 20);
    }
    return const Icon(Icons.chevron_right, color: Colors.black26, size: 24);
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // 배경 흰색
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // 홈 화면과 같은 그림자 농도
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false, // 위쪽은 SafeArea 무시 (내용물과 자연스럽게 연결)
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', false), // 현재 화면이 아니므로 false
              _buildNavItem(Icons.calendar_today, 'Event', false),
              _buildNavItem(Icons.track_changes, 'Quest', false),
              _buildNavItem(Icons.search, 'Community', true), // 현재 화면(예: Community)만 true
              _buildNavItem(Icons.person, 'Profile', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return InkWell( // 터치 효과 추가
      onTap: () {
        // 네비게이션 이동 로직
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFFA855F7) : const Color(0xFF9CA3AF), // 홈 화면과 동일한 색상
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFFA855F7) : const Color(0xFF9CA3AF),
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}