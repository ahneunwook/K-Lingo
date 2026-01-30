import 'package:flutter/material.dart';
import 'package:k_lingo_front/services/chapter_service.dart';
import 'package:k_lingo_front/models/study/chapter.dart';
import 'package:k_lingo_front/config/routes.dart';
// 👇 [추가] 공통 하단 바 import
import 'package:k_lingo_front/widgets/common_bottom_bar.dart';

class ChapterListScreen extends StatefulWidget {
  const ChapterListScreen({Key? key}) : super(key: key);

  @override
  State<ChapterListScreen> createState() => _ChapterListScreenState();
}

class _ChapterListScreenState extends State<ChapterListScreen> {
  final ChapterService _chapterService = ChapterService();
  
  List<Chapter>? _chapters;
  bool _isLoading = true;
  String? _error;
  bool _shouldReload = false; 

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final chapters = await _chapterService.getChapters("TOPIC");
      
      setState(() {
        _chapters = chapters;
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false, 
        titleSpacing: 0, 
        title: Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.pop(context, _shouldReload), // 변경사항 있으면 전달
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(), 
                style: const ButtonStyle(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 8), 
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vocabulary',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    '챕터 선택',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: _buildBody(),
      
      // 👇 [수정] 복잡한 코드 삭제하고 공통 위젯으로 교체!
      bottomNavigationBar: CommonBottomBar(
        currentIndex: 0, // Topic은 Home 탭의 하위 메뉴이므로 0번(Home) 활성화
        onTap: (index) {
          // 다른 탭을 누르면 메인 화면(MainScreen)으로 돌아가서 해당 탭을 보여줌
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
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
              onPressed: _loadChapters,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _chapters?.length ?? 0,
      itemBuilder: (context, index) {
        final chapter = _chapters![index];
        return _buildChapterCard(chapter);
      },
    );
  }

  Widget _buildChapterCard(Chapter chapter) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          onTap: () async {
            final result = await Navigator.pushNamed(
              context,
              Routes.stages,
              arguments: chapter,
            );
            
            if (result == true) {
              _shouldReload = true;
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFF3E5F5), Color(0xFFFCE4EC)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      chapter.icon,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chapter.nameEn,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        chapter.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.black26, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

}