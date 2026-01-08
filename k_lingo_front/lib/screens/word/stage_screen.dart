import 'package:flutter/material.dart';
import '../../services/word_stage_service.dart'; 
import '../../models/word/stage.dart'; 
import '../../models/word/word_category.dart';
import '../../config/routes.dart';

class StageScreen extends StatefulWidget {
  final WordCategory category;

  const StageScreen({Key? key, required this.category}) : super(key: key);

  @override
  State<StageScreen> createState() => _StageScreenState();
}

class _StageScreenState extends State<StageScreen> {
  // 제공해주신 WordStageService 클래스 사용
  final WordStageService _stageService = WordStageService();
  
  List<WordStage>? _stages;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // 화면이 생성되자마자 바로 로딩 시작
    _loadStages();
  }

  Future<void> _loadStages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // [핵심] _category 변수 대신 widget.category를 바로 사용합니다.
      final stages = await _stageService.getStages(widget.category.id);
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
        onPressed: () => Navigator.pop(context),
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
              // widget.category 사용
              child: Text(widget.category.icon ?? '📚', style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.category.nameKr, // widget.category 사용
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.category.nameEn, // widget.category 사용
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

  Widget _buildStageCard(WordStage stage) {
    // 모델 필드명이 nullable일 경우를 대비해 안전하게 처리
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
        // 퀴즈 화면으로 이동하고 결과 받기
        final result = await Navigator.pushNamed( 
            context,
            Routes.quiz,
            arguments: stage.id,
        );
    
        // 퀴즈 완료 후 돌아왔으면 새로고침
        if (result == true && mounted) { 
            _loadStages();
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
  Widget _buildStageIcon(WordStage stage) {
    Color backgroundColor;
    Widget icon;
    
    bool isLocked = stage.isLocked ?? false;
    bool isCleared = stage.isCleared ?? false;

    if (isLocked) {
      backgroundColor = const Color(0xFFE0E0E0);
      icon = const Icon(Icons.lock, color: Colors.white, size: 28);
    } else if (isCleared) {
      backgroundColor = const Color(0xFF4CAF50);
      icon = const Icon(Icons.check, color: Colors.white, size: 32);
    } else {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF9C27B0), Color(0xFFEC407A)],
          ),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Center(
          child: Text(
            '${stage.stageOrder ?? 0}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Center(child: icon),
    );
  }

  Widget _buildStageContent(WordStage stage) {
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

  Widget _buildStageTrailing(WordStage stage) {
    if (stage.isLocked ?? false) {
      return const Icon(Icons.lock, color: Colors.black12, size: 20);
    }
    return const Icon(Icons.chevron_right, color: Colors.black26, size: 24);
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFEC407A), Color(0xFF9C27B0)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', true),
              _buildNavItem(Icons.calendar_today, 'Event', false),
              _buildNavItem(Icons.track_changes, 'Quest', false),
              _buildNavItem(Icons.people, 'Community', false),
              _buildNavItem(Icons.person, 'Profile', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return InkWell(
      onTap: () {},
      child: Opacity(
        opacity: isActive ? 1.0 : 0.7,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}