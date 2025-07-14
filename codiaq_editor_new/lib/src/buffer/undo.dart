import 'package:codiaq_editor/codiaq_editor.dart';
import 'package:codiaq_editor/src/window/cursor.dart';
import 'package:flutter/foundation.dart';

enum ChangeDirection { undo, redo }

class UndoNode {
  final int top;
  final int bot;
  final List<String> before;
  final List<String> after;
  final CursorPosition cursorBefore;
  final CursorPosition cursorAfter;
  final DateTime time;

  UndoNode({
    required this.top,
    required this.bot,
    required this.before,
    required this.after,
    required this.cursorBefore,
    required this.cursorAfter,
  }) : time = DateTime.now();
}

class UndoTree extends ChangeNotifier {
  final Buffer buffer;

  final List<UndoNode> _undoStack = [];
  final List<UndoNode> _redoStack = [];

  UndoTree(this.buffer);

  /// Save both the before and after state to allow symmetric undo/redo
  void save({
    required int top,
    required int bot,
    required List<String> before,
    required List<String> after,
    required CursorPosition cursorBefore,
    required CursorPosition cursorAfter,
  }) {
    if (top < 0 || bot > buffer.lines.length || top > bot) {
      throw RangeError.range(top, 0, buffer.lines.length, 'top');
    }

    final newNode = UndoNode(
      top: top,
      bot: bot,
      before: before,
      after: after,
      cursorBefore: cursorBefore,
      cursorAfter: cursorAfter,
    );

    _undoStack.add(newNode);
    _redoStack.clear(); // Clear redo stack when new edit happens
    notifyListeners();
  }

  void undo() {
    if (_undoStack.isEmpty) return;

    final node = _undoStack.removeLast();
    _applyChanges(node, ChangeDirection.undo);
    _redoStack.add(node);

    notifyListeners();
  }

  void redo() {
    if (_redoStack.isEmpty) return;

    final node = _redoStack.removeLast();
    _applyChanges(node, ChangeDirection.redo);
    _undoStack.add(node);

    notifyListeners();
  }

  void _applyChanges(UndoNode node, ChangeDirection direction) {
    final content =
        direction == ChangeDirection.undo ? node.before : node.after;
    final cursor =
        direction == ChangeDirection.undo
            ? node.cursorBefore
            : node.cursorAfter;

    final clampedBot = node.bot.clamp(0, buffer.lines.length - 1);

    buffer.lines.replaceRange(
      CursorPosition(node.top, 0),
      CursorPosition(clampedBot, buffer.lines.get(clampedBot).length),
      content.join('\n'),
      silent: true,
    );

    buffer.setCursorPosition(cursor.line, cursor.column);
  }
}
