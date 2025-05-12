import 'dart:async';
import 'dart:io';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttr_app/gameComponents/jumpButton.dart';
import 'package:fluttr_app/gameComponents/player.dart';
import 'package:fluttr_app/gameComponents/level.dart';

class PixelGame extends FlameGame with DragCallbacks, HasCollisionDetection {
  @override
  Color backgroundColor() => const Color.fromARGB(255, 60, 157, 242);
  late final CameraComponent cam;
  Player player = Player(character: 'Ninja Frog');
  late JoystickComponent joystick;
  int score = 0;
  bool showControls = true;
  BuildContext? context;
  bool playSounds = false;
  double soundVolume = 1.0;
  // This method is setting and taking the method as paramenter

  // void _showWinOverlay(BuildContext context) {
  //   // Implement your logic to navigate back and show the dialog here
  //   Navigator.of(context).pop();
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text("You Won!",
  //             style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: const [
  //             Text("You Gained 100 Exp!", style: TextStyle(fontSize: 18)),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop(); // Close the dialog
  //               // You can also trigger a game reset here if needed
  //             },
  //             child: const Text("Close", style: TextStyle(fontSize: 16)),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  FutureOr<void> onLoad() async {
    // Load all images into cache
    await images.loadAllImages();
    await FlameAudio.audioCache.loadAll([
      'jump.wav',
      'collect.wav',
    ]);
    final world = Level(
      levelName: 'level_1.tmx',
      player: player,
    );
    cam = CameraComponent.withFixedResolution(
        world: world, width: 370, height: 700);
    cam.viewfinder.anchor = Anchor.topLeft;
    addAll([cam, world]);
    if (showControls) {
      addJoystick();

      add(JumpButton());
      // add(Scorecard());
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showControls) {
      _updateJoystick();
    }

    super.update(dt);
  }

  void addJoystick() {
    joystick = JoystickComponent(
      knob: CircleComponent(
          radius: 20,
          paint: Paint()..color = const Color.fromARGB(255, 4, 82, 146)),
      background: CircleComponent(
          radius: 40,
          paint: Paint()..color = const Color.fromARGB(110, 251, 251, 251)),
      margin: const EdgeInsets.only(left: 50, bottom: 32),
    );
    add(joystick);
  }

  void _updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
      case JoystickDirection.left:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
      case JoystickDirection.right:
        player.horizontalMovement = 1;
        break;
      default:
        player.horizontalMovement = 0;
    }
  }
}
