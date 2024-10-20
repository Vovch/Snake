import 'package:flutter/material.dart';
import 'snake_game.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black, // Added this line
        primarySwatch: Colors.blue,
      ),
      home: const SnakeGame(),
    );
  }
}
