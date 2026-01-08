import 'package:flutter/material.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/word/category_screen.dart';
import 'screens/word/stage_screen.dart';
import 'screens/word/quiz_screen.dart'; // import 확인
import 'config/routes.dart';
import 'models/word/word_category.dart';

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
        Routes.categories: (context) => const CategoryScreen(),
      },

      onGenerateRoute: (settings) {
        
        // 1. 스테이지 화면 이동
        if (settings.name == Routes.stages) {
          final category = settings.arguments as WordCategory;
          return MaterialPageRoute(
            builder: (context) => StageScreen(category: category),
          );
        }

        // 2. 퀴즈 화면 이동
        if (settings.name == Routes.quiz) {
          final stageId = settings.arguments as int; // 넘어온 stageId 받기
          return MaterialPageRoute(
            builder: (context) => QuizScreen(stageId: stageId), // 생성자에 넣어줌
          );
        }

        return null;
      },
    );
  }
}