import 'package:flutter/gestures.dart';

class NestedVerticalScrollGestureRecognizer extends VerticalDragGestureRecognizer {
  var scrollY = 0;

  @override
  void handleEvent(PointerEvent event) {
    if (event.delta.dy > 0.0 && scrollY <= 0) {
      resolve(GestureDisposition.rejected);
    } else {
      super.handleEvent(event);
    }
  }
}
