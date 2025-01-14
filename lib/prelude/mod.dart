import 'package:backbone/builders.dart';
import 'package:backbone/prelude/input/mod.dart';
import 'package:backbone/prelude/sprite/mod.dart';
import 'package:backbone/prelude/text/mod.dart';
import 'package:backbone/prelude/transform.dart';
import 'package:flame/game.dart';

void defaultPlugin<T extends FlameGame>(RealmBuilder<T> builder) {
  builder.withPlugin(transformPlugin<T>);
  builder.withPlugin(inputPlugin<T>);
  builder.withPlugin(textPlugin<T>);
  builder.withPlugin(spritePlugin<T>);
}
