import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:fluttr_app/pages/my_game.dart';

// ignore: must_be_immutable
class DailyChallenges extends StatelessWidget {
  DailyChallenges({super.key});
  MyGame myGame = MyGame();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daily Challenges"),
        backgroundColor: Colors.blueGrey,
      ),
      body: GameWidget(
        game: myGame,
      ),
    );
  }
}
