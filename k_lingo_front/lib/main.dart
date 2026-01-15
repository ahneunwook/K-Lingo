import 'package:flutter/material.dart';
import 'package:k_lingo_front/screens/splash/splash_screen.dart';
import 'package:k_lingo_front/screens/study/chapter_list_screen.dart';
import 'package:k_lingo_front/screens/study/stage_screen.dart';
import 'package:k_lingo_front/screens/word/quiz_screen.dart';
import 'package:k_lingo_front/config/routes.dart';
import 'package:k_lingo_front/models/study/chapter.dart';

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
        Routes.categories: (context) => ChapterListScreen(), // const 제거
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

        return null;
      },
    );
  }
}