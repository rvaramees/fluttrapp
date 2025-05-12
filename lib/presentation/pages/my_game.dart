import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttr_app/presentation/pages/pixel.dart';

class MainGamePage extends StatefulWidget {
  const MainGamePage({super.key});

  @override
  MainGamePageState createState() => MainGamePageState();
}

class MainGamePageState extends State<MainGamePage> {
  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    await Flame.device.fullScreen();
    await Flame.device.setPortrait();
  }

  PixelGame game = PixelGame();
  bool gameOver = false;

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: kDebugMode ? PixelGame() : game,
      overlayBuilderMap: {
        'GameOver': (BuildContext context, PixelGame game) {
          return Center(child: Text("OVER"));
        
        }
      },
    );
  }
}
