// import 'dart:async';

// import 'package:flame/components.dart';
// import 'package:flame/events.dart';
// import 'package:flame/palette.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttr_app/pages/home.dart';
// import 'package:fluttr_app/pages/pixel.dart';

// class Scorecard extends SpriteComponent with HasGameRef<PixelGame> {
//   // Removed TapCallbacks unless needed
//   Scorecard();

//   late TextComponent _scoreTextComponent;
//   final double margin = 10.0;

//   @override
//   FutureOr<void> onLoad() async {
//     // Use async for await
//     // --- FIX: Load and assign the sprite ---
//     // Make sure 'HUD/score_background.png' exists and is loaded by your game
//     // (e.g., in PixelGame's onLoad: await images.load('HUD/score_background.png'); )
//     sprite = Sprite(game.images.fromCache(
//         'Backrground/Blue.png')); // Or use game.images.fromCache if preloaded // Set size based on the loaded sprite

//     // --- Position the Scorecard ---
//     position = Vector2(
//       game.size.x - margin,
//       game.size.y - margin + 12,
//     );

//     // --- Text Component Setup ---
//     final style = TextStyle(
//       color: BasicPalette.white.color,
//       fontSize: 24.0,
//     );
//     final regular = TextPaint(style: style);

//     _scoreTextComponent = TextComponent(
//       text: 'Score: ${game.score}',
//       textRenderer: regular,
//       anchor: Anchor.center,
//       position: size / 2, // Center text within the component's size
//     );

//     add(_scoreTextComponent);

//     return super.onLoad();
//   }

//   @override
//   void update(double dt) {
//     super.update(dt);
//     final scoreString = 'Score: ${game.score}';
//     if (_scoreTextComponent.text != scoreString) {
//       _scoreTextComponent.text = scoreString;
//     }
//   }
// }
