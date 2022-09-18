import 'package:backbone/filter.dart';
import 'package:backbone/prelude/input/mod.dart';
import 'package:backbone/prelude/input/pointer.dart';
import 'package:backbone/realm.dart';
import 'package:backbone/trait.dart';

class TappableTrait extends ATrait {
  // Basic
  final void Function(Pointer pointer)? onTapDown;
  final void Function(Pointer pointer)? onLongTapDown;
  final void Function(Pointer pointer)? onTapUp;
  final void Function(Pointer pointer)? onTapCancel;

  // High-level
  final void Function(Pointer pointer)? onJustPressed;
  final void Function(Pointer pointer)? onPressed;
  final void Function(Pointer pointer)? onJustReleased;

  TappableTrait(
      {this.onTapDown,
      this.onLongTapDown,
      this.onTapUp,
      this.onTapCancel,
      this.onJustPressed,
      this.onPressed,
      this.onJustReleased});
}

void tappableSystem(Realm realm) {
  final query = realm.query(Has([TappableTrait]));
  final queryLength = query.length;
  final input = realm.getResource<Input>();
  final tapStarts = input.justTapDownPointers();
  final longTapStarts = input.justLongTapDownPointers();
  final tapEnds = input.justTapUpPointers();
  final tapCancels = input.justTapCancelPointers();
  final justPressed = input.justPressedPointers();
  final pressed = input.pressedPointers();
  final justReleased = input.justReleasedPointers();
  for (var i = 0; i < queryLength; i++) {
    final node = query.elementAt(i);
    final tappable = node.get<TappableTrait>();

    // Check tap starts
    for (var tapStart in tapStarts) {
      if (tappable.onTapDown != null) {
        if (node.containsPoint(tapStart.position)) {
          tappable.onTapDown!(tapStart);
        }
      }
    }

    // Check long tap starts
    for (var longTapStart in longTapStarts) {
      if (tappable.onLongTapDown != null) {
        if (node.containsPoint(longTapStart.position)) {
          tappable.onLongTapDown!(longTapStart);
        }
      }
    }

    // Check tap ends
    for (var tapEnd in tapEnds) {
      if (tappable.onTapUp != null) {
        if (node.containsPoint(tapEnd.position)) {
          tappable.onTapUp!(tapEnd);
        }
      }
    }

    // Check tap cancels
    for (var tapCancel in tapCancels) {
      if (tappable.onTapCancel != null) {
        if (node.containsPoint(tapCancel.position)) {
          tappable.onTapCancel!(tapCancel);
        }
      }
    }

    // Check just pressed
    for (var pressed in justPressed) {
      if (tappable.onJustPressed != null) {
        if (node.containsPoint(pressed.position)) {
          tappable.onJustPressed!(pressed);
        }
      }
    }

    // Check pressed
    for (var press in pressed) {
      if (tappable.onPressed != null) {
        if (node.containsPoint(press.position)) {
          tappable.onPressed!(press);
        }
      }
    }

    // Check just released
    for (var released in justReleased) {
      if (tappable.onJustReleased != null) {
        if (node.containsPoint(released.position)) {
          tappable.onJustReleased!(released);
        }
      }
    }
  }
}
