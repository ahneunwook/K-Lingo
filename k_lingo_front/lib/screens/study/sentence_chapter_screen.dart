import 'package:flutter/material.dart';
import 'package:k_lingo_front/models/study/chapter.dart';
import 'package:k_lingo_front/services/chapter_service.dart'; // 경로 확인 필요
import 'package:k_lingo_front/widgets/main_layout.dart'; 
import 'package:k_lingo_front/config/routes.dart';

class SentenceChapterScreen extends StatefulWidget {
  final String sectionType; 
  final String screenTitle;

  const SentenceChapterScreen({
    super.key,
    this.sectionType = 'SENTENCE', // 기본값 설정
    this.screenTitle = 'Sentence Training', // 기본값 설정
  });

  @override
  State<SentenceChapterScreen> createState() => _SentenceChapterScreenState();
}

class _SentenceChapterScreenState extends State<SentenceChapterScreen> {
  final ChapterService _chapterService = ChapterService();
  late Future<List<Chapter>> _chapterListFuture;

  @override
  void initState() {
    super.initState();
    _chapterListFuture = _chapterService.getChapters(widget.sectionType);
  }

  // 당겨서 새로고침 기능
  Future<void> _refreshChapters() async {
    setState(() {
        _chapterListFuture = _chapterService.getChapters(widget.sectionType);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: widget.screenTitle, // 제목만 입력
      bottomTabIndex: 2,          // "Quest" 탭에 불 들어오게 설정 (2번)
      body: FutureBuilder<List<Chapter>>(
        future: _chapterListFuture,
        builder: (context, snapshot) {
          // 1. 로딩 중일 때
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. 에러가 났을 때
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 10),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _refreshChapters,
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          // 3. 데이터가 없을 때
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('등록된 챕터가 없습니다.'));
          }

          // 4. 데이터가 성공적으로 왔을 때
          final chapters = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refreshChapters,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: chapters.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final chapter = chapters[index];
                return _buildChapterCard(chapter);
              },
            ),
          );
        },
      ),
    );
  }

  // 챕터 카드 위젯 (디자인)
  Widget _buildChapterCard(Chapter chapter) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.pushNamed(
              context, 
              Routes.sentenceQuiz, // 1. 경로 이름
              arguments: chapter.id, // 2. 넘겨줄 데이터 (챕터 ID)
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // 1. 아이콘 이미지
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: chapter.icon.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.network(
                            chapter.icon,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.broken_image, color: Colors.grey);
                            },
                          ),
                        )
                      : const Icon(Icons.school, color: Colors.blue),
                ),
                
                const SizedBox(width: 16),

                // 2. 텍스트 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 영어 제목 (메인)
                      Text(
                        chapter.nameEn,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // 한국어 제목 (서브)
                      Text(
                        chapter.nameKr,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // 설명 (Description)
                      Text(
                        chapter.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis, // 2줄 넘어가면 ... 처리
                      ),
                    ],
                  ),
                ),

                // 3. 화살표 아이콘
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}