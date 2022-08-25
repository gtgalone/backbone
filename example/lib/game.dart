import 'dart:math';

import 'package:backbone/builders.dart';
import 'package:backbone/prelude/transform.dart';
import 'package:backbone/world.dart';
import 'package:example/bouncer.dart';
import 'package:example/systems.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: MainGame(context)..debugMode = false,
    );
  }
}

class MainGame extends FlameGame with HasTappables, MultiTouchTapDetector {
  /// Flutter build context of the parent widget, required for assets
  final BuildContext context;
  late final World world;
  MainGame(this.context);

  @override
  void onTapDown(int pointerId, TapDownInfo info) {
    world.onTapDown(pointerId, info);
    super.onTapDown(pointerId, info);
  }

  @override
  void onTapUp(int pointerId, _) {
    world.onTapUp(pointerId, _);
    super.onTapUp(pointerId, _);
  }

  @override
  void onTapCancel(int pointerId) {
    world.onTapCancel(pointerId);
    super.onTapCancel(pointerId);
  }

  @override
  Future<void> onLoad() async {
    world = WorldBuilder()
        .withPlugin(transformPlugin)
        .withTrait(BouncerTrait)
        .withSystem(bounceSystem)
        .withSystem(tapSpawnSystem)
        .build();
    add(world);

    // Generate some bouncers
    var rng = Random();
    for (var i = 0; i < 5; i++) {
      final bouncer = BouncerNode(
          Vector2.all(50.0 + 50.0 * rng.nextDouble()),
          Color.fromARGB(
              255,
              (rng.nextDouble() * 255.0).toInt(),
              (rng.nextDouble() * 255.0).toInt(),
              (rng.nextDouble() * 255.0).toInt()),
          (Vector2.all(-1.0) + Vector2.random(rng) * 2.0),
          200.0 + 200.0 * rng.nextDouble());
      bouncer.transform.position = Vector2(canvasSize.x / 2, canvasSize.y / 2);
      world.add(bouncer);
    }
  }
}