import 'package:backbone/filter.dart';
import 'package:backbone/node.dart';
import 'package:backbone/prelude/input/mod.dart';
import 'package:backbone/prelude/input/plugins/hoverable.dart';
import 'package:backbone/prelude/input/pointer.dart';
import 'package:backbone/prelude/transform.dart';
import 'package:backbone/realm.dart';
import 'package:backbone/trait.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';

class DraggablePointerPayload {
  final ANode initiator;
  final dynamic data;

  DraggablePointerPayload(this.initiator, this.data);
}

class DraggableTrait<T extends FlameGame> extends ATrait<T> {
  final DraggablePointerPayload? Function(Pointer pointer, Vector2 offset)?
      onStart;
  final void Function(Pointer pointer)? onUpdate;
  final void Function(Pointer pointer)? onEnd;

  DraggableTrait({this.onStart, this.onUpdate, this.onEnd});
}

class DragReceiverTrait<T extends FlameGame> extends ATrait<T> {
  final void Function(Pointer pointer, DraggablePointerPayload? payload)
      onReceive;

  DragReceiverTrait({required this.onReceive});
}

void draggableSystem<T extends FlameGame>(Realm<T> realm) {
  // Dependencies to maintain order
  realm.checkOrRunSystem(hoverableSystem);

  final input = realm.getResource<Input>();
  final dragStarts = input.justDragStartPointers();
  final dragUpdates = input.justDragUpdatePointers();
  final dragEnds = input.justDragEndPointers();
  if (dragStarts.isEmpty && dragUpdates.isEmpty && dragEnds.isEmpty) return;

  final query = realm.query(Has([DraggableTrait<T>]));
  final foundDragStarts = [];

  for (final node in query) {
    final draggable = node.get<DraggableTrait<T>>();
    final tranform = node.tryGet<TransformTrait<T>>();

    // Check drag starts
    for (var dragStart in dragStarts) {
      // Find a state which existed right before the tap cancell
      final state = dragStart.history.lastWhere(
          (state) => state is PointerStateDown || state is PointerStateLongDown,
          orElse: () =>
              throw 'Tap down event not found for the drag start position correction');
      final point = dragStart.worldPosition(realm.gameRef, fromState: state);
      if (node.containsPoint(point)) {
        if (draggable.onStart != null) {
          final offset = tranform != null
              ? dragStart.worldPosition(realm.gameRef, fromState: state) -
                  tranform.absolutePosition(node)
              : Vector2.zero();
          foundDragStarts.add({
            'node': node,
            'draggable': draggable,
            'pointer': dragStart,
            'offset': offset,
          });
        }
      }
    }

    // Check drag updates
    for (var dragUpdate in dragUpdates) {
      if (dragUpdate.payload == null) continue;

      if ((dragUpdate.payload as DraggablePointerPayload?)?.initiator == node) {
        if (draggable.onUpdate != null) {
          draggable.onUpdate!(dragUpdate);
        }
      }
    }

    // Check drag ends
    for (var dragEnd in dragEnds) {
      if (dragEnd.payload == null) continue;

      if ((dragEnd.payload as DraggablePointerPayload?)?.initiator == node) {
        if (draggable.onEnd != null) {
          draggable.onEnd!(dragEnd);
        }
      }
    }
  }

  // Call the callbacks based on the node's priority
  final foundDragStartsSorted = (foundDragStarts.toList()
        ..sort((a, b) => a["node"].compareToOnPriority(b["node"])))
      .reversed;
  for (final dragStart in foundDragStartsSorted) {
    final node = dragStart["node"];
    final draggable = node.get<DraggableTrait<T>>();
    final pointer = dragStart["pointer"];
    if (pointer.handled) continue; // Otherwise we would override the
    final offset = dragStart["offset"];
    final payload = draggable.onStart!(pointer, offset);
    assert(payload == null || (pointer.handled && payload != null),
        'You need to mark the pointer as handled to use it, if you provide a payload. Set pointer.handled = true!');
    if (pointer.handled) {
      pointer.payload = payload;
    }
  }
}

void dragReceiverSystem<T extends FlameGame>(Realm<T> realm) {
  // Dependencies to maintain order
  realm.checkOrRunSystem(draggableSystem);

  final input = realm.getResource<Input>();
  final dragEnds = input.justDragEndPointers();
  if (dragEnds.isEmpty) return;
  final query = realm.query(Has([DragReceiverTrait<T>]));

  for (final node in query) {
    final dragReceiver = node.get<DragReceiverTrait<T>>();

    // Check drag ends
    for (var dragEnd in dragEnds) {
      if (node.containsPoint(dragEnd.worldPosition(realm.gameRef))) {
        final payload = dragEnd.payload as DraggablePointerPayload?;
        dragReceiver.onReceive(dragEnd, payload);
      }
    }
  }
}
