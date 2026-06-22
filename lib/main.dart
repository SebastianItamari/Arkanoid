import 'package:arkanoid/screens/game_screen.dart';
import 'package:arkanoid/screens/start_screen.dart';
import 'package:arkanoid/theme/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => StartScreen(),
        '/game': (context) => GameScreen(),
      },
    );
  }
}
