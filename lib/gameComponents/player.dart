import 'dart:async';

import 'package:brighter_bites/gameComponents/checkpoint.dart';
import 'package:brighter_bites/gameComponents/collision_block.dart';
import 'package:brighter_bites/gameComponents/customHitbox.dart';
import 'package:brighter_bites/gameComponents/fruit.dart';
import 'package:brighter_bites/gameComponents/utils.dart';
import 'package:brighter_bites/presentation/pages/pixel.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';

enum PlayerState { idle, running, jumping, falling }

// enum PlayerDirection { left, right, none }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelGame>, CollisionCallbacks {
  String character;
  Player({position, this.character = 'Ninja Frog'}) : super(position: position);
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;

  final double stepTime = 0.05;
  double moveSpeed = 100;
  double horizontalMovement = 0.0;
  final double _gravity = 9.8;
  final double jumpForce = 200;
  final double terminalVelocity = 300;
  bool isOnGround = true;
  bool hasJumped = false;
  bool reachedCheckpoint = false;
  List<CollisionBlock> collisionBlocks = [];
  CustomHitbox hitbox = CustomHitbox(
    offsetX: 10,
    offsetY: 4,
    width: 12,
    height: 28,
  );

  // CustomHitboxDirection playerDirection = PlayerDirection.none;
  Vector2 velocity = Vector2.zero();
  bool isFacingRight = true;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
    ));
    debugMode = false;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerState(dt);
    _updatePlayerDirection(dt);
    _checkHorizontalCollisions();
    _checkVerticalCollisions();
    _applyGravity(dt);
    super.update(dt);
    // Update the position of the player based on velocity and dt
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Fruit) {
      other.collidedWithPlayer();
    }
    if (other is Checkpoint && !reachedCheckpoint) _reachedCheckpoint();
    super.onCollision(intersectionPoints, other);
  }

  void _loadAllAnimations() {
    // Idle Animation
    idleAnimation = _spriteAnimation('Idle', 11);
    // Running Animation
    runningAnimation = _spriteAnimation('Run', 12);
    // Jumping Animation
    jumpingAnimation = _spriteAnimation('Jump', 1);
    // Falling Animation
    fallingAnimation = _spriteAnimation('Fall', 1);
    // List of all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
    };
    // Set current animation
    current = PlayerState.idle;
  }

  // Sprite Animation
  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
        game.images.fromCache('Main Characters/$character/$state (32x32).png'),
        SpriteAnimationData.sequenced(
            amount: amount, stepTime: stepTime, textureSize: Vector2.all(32)));
  }

  void _updatePlayerState(double dt) {
    PlayerState playerState = PlayerState.idle;

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    if (velocity.x < 0 || velocity.x > 0) {
      playerState = PlayerState.running;
    } else {
      playerState = PlayerState.idle;
    }

    // if (isOnGround) PlayerState.idle;
    // if (velocity.y > 0) {
    //   playerState = PlayerState.falling;
    // }
    // Check if player is jumping or falling
    if (velocity.y < 0) {
      playerState = PlayerState.jumping;
    }
    current = playerState;
  }

  void _updatePlayerDirection(double dt) {
    if (hasJumped && isOnGround) _playerJump(dt);
    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _playerJump(double dt) {
    if (game.playSounds) {
      FlameAudio.play('jump.wav', volume: game.soundVolume);
    }
    velocity.y = -jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
            break;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-jumpForce, terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
        } else {
          if (checkCollision(this, block)) {
            if (velocity.y > 0) {
              velocity.y = 0;
              position.y = block.y - hitbox.height - hitbox.offsetY;
              isOnGround = true;
              break;
            }
            if (velocity.y < 0) {
              velocity.y = 0;
              position.y = block.y + block.height - hitbox.offsetY;
              isOnGround = false;
              break;
            }
          }
        }
      }
    }
  }

  void _reachedCheckpoint() {
    reachedCheckpoint = true;
    Future.delayed(const Duration(seconds: 2), () {
      
    });
  }

  
}
