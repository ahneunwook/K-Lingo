import 'package:flutter/material.dart';
import '../../services/word_stage_service.dart';
import '../../models/word/stage.dart';
import '../../models/word/word_category.dart';

class StageScreen extends StatefulWidget {
  // 1️⃣ 생성자에서 'required category'를 제거했습니다.
  // 이제 main.dart에서 에러가 안 납니다.
  const StageScreen({Key? key}) : super(key: key);

  @override
  State<StageScreen> createState() => _StageScreenState();
}

class _StageScreenState extends State<StageScreen> {
  // 2️⃣ WordService -> WordStageService로 변경
  final WordStageService _stageService = WordStageService();
  
  WordCategory? _category; // 받아온 카테고리 정보를 저장할 변수
  List<WordStage>? _stages;
  bool _isLoading = true;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 3️⃣ 화면이 열릴 때 넘겨받은 데이터(arguments)를 꺼냅니다.
    if (_category == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      
      // arguments가 Map으로 들어왔을 때 (categoryId만 있는 경우) -> 처리가 복잡함
      // arguments가 WordCategory 객체 자체일 때 -> 베스트!
      if (args is WordCategory) {
        _category = args;
        _loadStages();
      } else if (args is Map && args.containsKey('category')) {
          _category = args['category'] as WordCategory;
          _loadStages();
      }
    }
  }

  Future<void> _loadStages() async {
    if (_category == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 4️⃣ _stageService를 사용하므로 getStages 호출 가능!
      final stages = await _stageService.getStages(_category!.id);
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
    // 카테고리 정보가 없으면 로딩 중이거나 에러
    if (_category == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    // 5️⃣ widget.category 대신 _category! 사용
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
              // _category 변수 사용
              child: Text(_category!.icon, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _category!.nameKr,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _category!.nameEn,
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _stages?.length ?? 0,
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
    // WordStage 모델에 isLocked, isCleared 필드가 있다고 가정
    // 만약 모델 필드명이 다르다면 수정 필요 (예: stage.locked 등)
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
          onTap: isLocked ? null : () {
            Navigator.pushNamed(
              context,
              '/quiz',
              arguments: {'stageId': stage.id},
            );
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
            '${stage.stageOrder ?? 0}', // null 방지
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
        // bestScore가 null일 수 있으므로 0으로 처리
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
      scoreColor = const Color(0xFF4CAF50); // Green
    } else if (score >= 5) {
      scoreColor = const Color(0xFFFF9800); // Orange
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

  // 하단 네비게이션은 그대로 유지
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