import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/word/category_screen.dart';
import 'config/routes.dart';

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
      // theme: AppTheme.lightTheme,

      theme: ThemeData(
        fontFamily: 'Pretendard',
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        primarySwatch: Colors.blue,
      ),

      home: const SplashScreen(),

      routes: {
        Routes.categories: (context) => const CategoryScreen(),
      },
    );
  }
}

