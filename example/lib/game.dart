import 'dart:math';

import 'package:backbone/backbone.dart';
import 'package:backbone/builders.dart';
import 'package:backbone/logging/log.dart';
import 'package:backbone/realm_mixin.dart';
import 'package:example/bouncer.dart';
import 'package:example/bouncer_counter.dart';
import 'package:example/message_systems.dart';
import 'package:example/systems.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:perfmon_logger/perfmon_logger.dart';

import 'template_bar.dart';
import 'messages.dart';

class MainGame extends FlameGame
    with
        HasTappableComponents,
        HasDraggableComponents,
        KeyboardEvents,
        HasRealm {
  @override
  Future<void> onLoad() async {
    Log? logger;
    if (kProfileMode) {
      logger = PerfmonLogger();
    }
    realm = RealmBuilder()
        .withPlugin(defaultPlugin)
        .withTrait(BouncerTrait)
        .withTrait(GameResizeTrait)
        .withTrait(TemplateSpawnerTrait)
        .withTrait(BouncerCounterTrait)
        .withSystem(bouncerCounterSystem)
        .withSystem(bounceSystem)
        .withSystem(tapSpawnSystem)
        .withSystem(deleteRemoveSystem)
        .withMessageSystem(removeBounceMessageSystem)
        .withMessageSystem(resizeMessageSystem)
        .build(realmLogger: logger);
    add(realm);

    // Generate some bouncers
    final rng = Random();
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
      bouncer.transformTrait.position =
          Vector2(canvasSize.x / 2, canvasSize.y / 2);
      realm.add(bouncer);
    }
    realm.add(TemplateBar(size));
    realm.add(BouncerCounterNode());
    realmReady = true;
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    if (realmReady) {
      realm.pushMessage(GameResizseMessage());
    }
  }
}
