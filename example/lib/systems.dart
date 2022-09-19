import 'dart:math';

import 'package:backbone/filter.dart';
import 'package:backbone/prelude/input/mod.dart';
import 'package:backbone/prelude/time.dart';
import 'package:backbone/prelude/transform.dart';
import 'package:backbone/realm.dart';
import 'package:example/bouncer.dart';
import 'package:flame/extensions.dart';

import 'drag_bar.dart';

/// System that bounces boxes off screen edges
void bounceSystem(Realm realm) {
  final time = realm.getResource<Time>();
  final realmQuery = realm.query(Has([TransformTrait, BouncerTrait]));
  // or
  // final realmQuery = realm.query(And([Has([TransformTrait]), Has([BouncerTrait])]));
  final dragBarQuery = realm.query(Has([DragBoxSpawnerTrait, TransformTrait]));
  final dragBarTransform = dragBarQuery.first.get<TransformTrait>();
  final queryLength = realmQuery.length;
  final dragBarSize = Vector2(
      dragBarTransform.position.y == 0 ? DragBar.space : 0,
      dragBarTransform.position.x == 0 ? DragBar.space : 0);
  final gameSizeWithoutDragBar = realm.gameRef.canvasSize - dragBarSize;
  for (var i = 0; i < queryLength; i++) {
    final node = realmQuery.elementAt(i) as BouncerNode;
    final transform = node.transformTrait;

    // Move them in the direction at the speed of `speed` pixels per second
    transform.position += node.direction.normalized() * time.delta * node.speed;

    // Now bounce them from edges
    if (transform.position.x < 0) {
      node.direction.x = node.direction.x.abs();
    }
    if (transform.position.x + transform.size.x > gameSizeWithoutDragBar.x) {
      node.direction.x = -node.direction.x.abs();
    }
    if (transform.position.y < 0) {
      node.direction.y = node.direction.y.abs();
    }
    if (transform.position.y + transform.size.y > gameSizeWithoutDragBar.y) {
      node.direction.y = -node.direction.y.abs();
    }
  }
}

/// System that spawns new boxes on click
void tapSpawnSystem(Realm realm) {
  final rng = Random();
  final input = realm.getResource<Input>();
  final pointers = input.justReleasedPointers();
  for (var pointer in pointers) {
    if (pointer.handled == false) {
      final bouncer = BouncerNode(
          Vector2.all(50.0 + 50.0 * rng.nextDouble()),
          Color.fromARGB(
              255,
              (rng.nextDouble() * 255.0).toInt(),
              (rng.nextDouble() * 255.0).toInt(),
              (rng.nextDouble() * 255.0).toInt()),
          (Vector2.all(-1.0) + Vector2.random(rng) * 2.0),
          200.0 + 200.0 * rng.nextDouble());
      bouncer.transformTrait.position = pointer.position;
      realm.add(bouncer);
    }
  }
}
