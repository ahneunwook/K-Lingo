import 'package:flutter/material.dart';
import 'package:k_lingo_front/screens/splash/splash_screen.dart';
import 'package:k_lingo_front/screens/study/chapter_list_screen.dart';
import 'package:k_lingo_front/screens/study/stage_screen.dart';
import 'package:k_lingo_front/screens/word/quiz_screen.dart';
import 'package:k_lingo_front/config/routes.dart';
import 'package:k_lingo_front/models/study/chapter.dart';
import 'package:k_lingo_front/screens/study/sentence_chapter_screen.dart';
import 'package:k_lingo_front/screens/study/sentence_quiz_screen.dart';
import 'package:k_lingo_front/screens/home/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KoreanMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Pretendard',
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        primarySwatch: Colors.blue,
      ),

      home: const SplashScreen(),

      routes: {
        '/main': (context) => const MainScreen(),

        // 1. 단어장 (기존)
        Routes.categories: (context) => ChapterListScreen(), 
        
        // 2. 문장 공부 (기존) - 명시적으로 파라미터 넣어주는 게 좋습니다.
        Routes.sentenceChapters: (context) => const SentenceChapterScreen(
          sectionType: 'SENTENCE',
          screenTitle: 'Sentence Training',
        ),

        // 3. ✨ [추가] K-Drama
        Routes.dramaChapters: (context) => const SentenceChapterScreen(
          sectionType: 'KDRAMA',        // 백엔드에 'KDRAMA' 타입 요청
          screenTitle: 'K-Drama Learning', // 앱바 제목
        ),

        // 4. ✨ [추가] K-Pop
        Routes.kpopChapters: (context) => const SentenceChapterScreen(
          sectionType: 'KPOP',          // 백엔드에 'KPOP' 타입 요청
          screenTitle: 'K-Pop Sing Along', // 앱바 제목
        ),
      },

      onGenerateRoute: (settings) {
        
        if (settings.name == Routes.stages) {
          final chapter = settings.arguments as Chapter; // WordCategory → Chapter
          return MaterialPageRoute(
            builder: (context) => StageScreen(chapter: chapter),
          );
        }

        if (settings.name == Routes.quiz) {
          final stageId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => QuizScreen(stageId: stageId),
          );
        }
        
        if (settings.name == Routes.sentenceQuiz) {
          // pushNamed 할 때 넘겨준 arguments(chapterId)를 받음
          final chapterId = settings.arguments as int; 
          
          return MaterialPageRoute(
            builder: (context) => SentenceQuizScreen(chapterId: chapterId),
          );
        }
        return null;
      },
    );
  }
}