import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:fluttr_app/gameComponents/checkpoint.dart';
import 'package:fluttr_app/gameComponents/collision_block.dart';
import 'package:fluttr_app/gameComponents/fruit.dart';
import 'package:fluttr_app/gameComponents/player.dart';
import 'package:fluttr_app/presentation/pages/pixel.dart';

class Level extends World with HasGameRef<PixelGame> {
  late TiledComponent level;
  final String levelName;
  final Player player;

  Level({
    required this.levelName,
    required this.player,
  });
  List<CollisionBlock> collisionBlocks = [];

  @override
  FutureOr<void> onLoad() async {
    // TODO: implement onLoad

    level = await TiledComponent.load('level_1.tmx', Vector2.all(16));
    add(level);
    // _scrollingBackground();
    _spawningObjects();
    _addCollision();

    return super.onLoad();
  }

  void _spawningObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('SpawnPoint');
    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(player);
            break;
          case 'Fruits':
            final fruit = Fruit(
              fruit: spawnPoint.name,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(fruit);
          case 'Checkpoint':
            final checkpoint = Checkpoint(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );

            add(checkpoint);
            break;

          default:
        }
      }
    } else {
      print('SpawnPoint layer not found in the level map.');
    }
  }

  void _addCollision() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');
    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case 'Platform':
            final platform = CollisionBlock(
                position: Vector2(collision.x, collision.y),
                size: Vector2(collision.width, collision.height),
                isPlatform: true);
            collisionBlocks.add(platform);
            add(platform);
            break;
          default:
            final block = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: false,
            );
            collisionBlocks.add(block);
            add(block);
            break;
        }
      }
    }
    player.collisionBlocks = collisionBlocks;
  }

  // void _scrollingBackground() {
  //   final backgroundLayer = level.tileMap.getLayer('Background');
  //   if (backgroundLayer != null) {
  //     final backgroundColor =
  //         backgroundLayer.properties.getValue('BackgroundColor');

  //   }
  // }
}
