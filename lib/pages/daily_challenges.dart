import 'package:flutter/material.dart';
// import 'package:flame/game.dart';
import 'package:fluttr_app/pages/my_game.dart';

// ignore: must_be_immutable
class DailyChallenges extends StatelessWidget {
  DailyChallenges({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tetris',
      home: MainGamePage(),
    );
  }
}
