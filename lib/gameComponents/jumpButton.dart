import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:fluttr_app/presentation/pages/pixel.dart';

class JumpButton extends SpriteComponent
    with HasGameRef<PixelGame>, TapCallbacks {
  JumpButton();

  final margin = 32;
  final buttonSize = 70.0;

  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache('HUD/jump.png'));
    final padding = 16.0;
    position = Vector2(
      game.size.x - buttonSize - padding - margin,
      game.size.y - buttonSize - padding - margin + 12,
    );
    size = Vector2(buttonSize, buttonSize);
    priority = 10;
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.player.hasJumped = true;
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.player.hasJumped = false;
    super.onTapUp(event);
  }
}
