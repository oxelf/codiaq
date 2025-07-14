import 'package:flutter/widgets.dart';

import '../window/cursor.dart';
import 'buffer.dart';
import 'event.dart';

enum PopupDirection { left, right, bottom, top }

extension PopupOffset on PopupDirection {
  Offset getOffset() {
    if (this == PopupDirection.left) {
      return Offset(-5, 10);
    } else if (this == PopupDirection.bottom) {
      return Offset(10, 20);
    } else if (this == PopupDirection.top) {
      return Offset(0, 100);
    } else {
      return Offset(20, 0);
    }
  }
}

abstract class BasePopupController {
  void onClose() {}
  bool onKeyEvent(KeyEvent event) {
    return false;
  }

  late Popup self;
}

class ArbitraryPopupPosition {
  final double x;
  final double y;

  ArbitraryPopupPosition(this.x, this.y);
}

class Popup {
  final int zIndex;
  final bool closeOnExit;
  final bool closeOnTapOutside;
  final dynamic type;
  final Widget content;
  final CursorPosition position;
  final PopupDirection direction;
  final ArbitraryPopupPosition? arbitraryPosition;
  final GlobalKey key;
  final bool disallowOtherPopups;
  BasePopupController? get controller =>
      key.currentState is BasePopupController
          ? key.currentState as BasePopupController
          : null;

  Popup({
    required this.zIndex,
    required this.content,
    required this.position,
    required this.type,
    required this.key,
    this.disallowOtherPopups = false,
    this.arbitraryPosition,
    this.closeOnExit = true,
    this.closeOnTapOutside = false,
    this.direction = PopupDirection.bottom,
  });
}

class PopupManager {
  final List<Popup> _popups = [];
  final Buffer buffer;

  PopupManager(this.buffer);

  void addPopup(Popup popup) {
    if (popup.type == "hover" &&
        _popups.indexWhere((p) => p.type == "hover") != -1) {
      return;
    }
    if (_popups.any((p) => p.disallowOtherPopups && p.type != popup.type)) {
      return; // Disallow other popups if one is already present
    }
    if (popup.disallowOtherPopups) {
      clear();
    }
    buffer.events.emit(BufferEventType.popupInserted.index);
    _popups.add(popup);
  }

  void removePopup(Popup popup) {
    print("Removing popup: ${popup.type}");
    _popups.remove(popup);

    buffer.events.emit(BufferEventType.popupRemoved.index);
  }

  void removePopupByType(String type) {
    print("Removing popup by type: $type");
    _popups.removeWhere((popup) => popup.type == type);
    buffer.events.emit(BufferEventType.popupRemoved.index);
  }

  void clear() {
    print("Clearing all popups");
    _popups.clear();
    buffer.events.emit(BufferEventType.popupRemoved.index);
  }

  List<Popup> get popups => List.unmodifiable(_popups);
}
