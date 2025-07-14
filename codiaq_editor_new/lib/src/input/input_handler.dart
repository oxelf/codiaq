import 'package:codiaq_editor/src/actions/action_event.dart';
import 'package:codiaq_editor/src/actions/keyboard_shortcut.dart';
import 'package:codiaq_editor/src/actions/keymap_manager.dart';
import 'package:codiaq_editor/src/actions/keystroke.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../buffer/buffer.dart';
import '../window/cursor.dart';
import '../window/selection.dart';

class InputHandler {
  final Buffer buffer;
  KeymapManager keymapManager = KeymapManager();
  bool ctrlPressed = false;
  bool shiftPressed = false;
  bool altPressed = false;
  bool metaPressed = false;

  InputHandler(this.buffer);

  KeyStroke keyStrokeFromLogicalKey(LogicalKeyboardKey key, bool keyDown) {
    return KeyStroke.fromLogicalKey(
      key,
      modifiers: Modifiers.construct(
        ctrl: ctrlPressed,
        shift: shiftPressed,
        alt: altPressed,
        meta: metaPressed,
      ),
      onKeyRelease: !keyDown,
    );
  }

  void onInsert(String text) {
    if (text.isEmpty) return;

    if (text == '\n') {
      _handleEnter();
      return;
    }

    // Insert the text at the current cursor position
    _writeChar(text);
    buffer.completions.updateWithLsp();
  }

  bool handleKeyStroke(KeyStroke keyStroke) {
    // 1️⃣ Let plugins handle it first
    print("handling keystroke: ${keyStroke.toString()}");
    KeyboardShortcut shortcut = KeyboardShortcut(firstKeyStroke: keyStroke);
    var handlers = keymapManager.getActionsForShortcut(shortcut);
    print("Handlers for $shortcut: $handlers (len: ${handlers.length})");

    for (var handler in handlers) {
      handler.performAction(ActionEvent(buffer: buffer));
    }
    if (handlers.isNotEmpty) {
      return true; // Handled by a plugin
    }
    return false;
  }

  KeyEventResult onKeyEvent(FocusNode focusNode, KeyEvent event) {
    _updateModifierStates(event);

    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      final keyStroke = keyStrokeFromLogicalKey(event.logicalKey, true);

      if (handleKeyStroke(keyStroke)) {
        // If a plugin handled the keystroke, we don't need to process it further
        return KeyEventResult.handled;
      }
      onInsert(event.character ?? '');

      return KeyEventResult.handled;
      //return _handleCoreKeyEvent(event);
    }

    return KeyEventResult.ignored;
  }

  void _updateModifierStates(KeyEvent event) {
    var ctrlVariants = [
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.controlRight,
      LogicalKeyboardKey.control,
    ];

    var shiftVariants = [
      LogicalKeyboardKey.shiftLeft,
      LogicalKeyboardKey.shiftRight,
      LogicalKeyboardKey.shift,
    ];

    var metaVariants = [
      LogicalKeyboardKey.metaLeft,
      LogicalKeyboardKey.metaRight,
      LogicalKeyboardKey.meta,
    ];
    var altVariants = [
      LogicalKeyboardKey.altLeft,
      LogicalKeyboardKey.altRight,
      LogicalKeyboardKey.alt,
    ];
    if (event is KeyUpEvent) {
      if (ctrlVariants.contains(event.logicalKey)) {
        ctrlPressed = false;
      }
      if (shiftVariants.contains(event.logicalKey)) {
        shiftPressed = false;
      }
      if (metaVariants.contains(event.logicalKey)) {
        metaPressed = false;
      }
      if (altVariants.contains(event.logicalKey)) {
        altPressed = false;
      }
    } else if (event is KeyDownEvent) {
      if (ctrlVariants.contains(event.logicalKey)) {
        ctrlPressed = true;
      }
      if (shiftVariants.contains(event.logicalKey)) {
        shiftPressed = true;
      }
      if (metaVariants.contains(event.logicalKey)) {
        metaPressed = true;
      }
      if (altVariants.contains(event.logicalKey)) {
        altPressed = true;
      }
    }
    print(
      "Modifiers: ctrl=$ctrlPressed, shift=$shiftPressed, "
      "alt=$altPressed, meta=$metaPressed",
    );
  }

  KeyEventResult _handleCoreKeyEvent(KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      _handleBackspace();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _handleArrowLeft();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _handleArrowRight();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _handleArrowUp();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _handleArrowDown();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      _handleEnter();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _handleEscape();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.keyQ && ctrlPressed) {
      print("Ctrl+Q pressed, triggering hover");
      buffer.triggerHover(buffer.cursor.line, buffer.cursor.column);
      return KeyEventResult.handled;
    }
    if (buffer.vim.vimEnabled) {
      if (buffer.vim.handleEvent(event)) {
        return KeyEventResult.handled;
      }
    }
    String char = event.character ?? '';
    if (event.logicalKey == LogicalKeyboardKey.tab) {
      char = ' ' * buffer.theme.tabSize;
      print("Tab pressed, inserting '$char'");
    }
    if (char.isEmpty) {
      // Ignore empty characters
      return KeyEventResult.handled;
    }
    _writeChar(char);
    if (char.trim().isNotEmpty) {
      buffer.completions.updateWithLsp();
    }
    return KeyEventResult.handled;
  }

  void _writeChar(String char) {
    buffer.lines.insertAt(buffer.cursor.line, buffer.cursor.column, char);

    buffer.setCursorPosition(
      buffer.cursor.line,
      buffer.cursor.column + char.length,
    );
  }

  void _handleArrowLeft() {
    moveLeft(selecting: shiftPressed);
  }

  void _handleArrowRight() {
    moveRight(selecting: shiftPressed);
  }

  void _handleArrowUp() {
    moveUp(selecting: shiftPressed);
  }

  void _handleArrowDown() {
    moveDown(selecting: shiftPressed);
  }

  // insert line below with text after the cursor.
  // move cursor to the start of the new line.
  void _handleEnter() {
    final currentLine = buffer.lines[buffer.cursor.line];
    final textAfterCursor = currentLine.substring(buffer.cursor.column);
    final newLineText = currentLine.substring(0, buffer.cursor.column);

    // Insert new line
    buffer.lines.insert(buffer.cursor.line + 1, textAfterCursor);

    // Update the current line
    buffer.lines[buffer.cursor.line] = newLineText;

    // Move cursor to the start of the new line
    buffer.setCursorPosition(buffer.cursor.line + 1, 0);
  }

  void _handleEscape() {
    buffer.vim.esc();
  }

  void _handleBackspace() {
    if (buffer.selection.isActive) {
      var newCursorPosition = buffer.selection.start;
      if (buffer.selection.end!.line < buffer.selection.start!.line) {
        newCursorPosition = buffer.selection.end;
      }
      if (buffer.selection.end!.line == buffer.selection.start!.line &&
          buffer.selection.end!.column < buffer.selection.start!.column) {
        newCursorPosition = buffer.selection.end;
      }
      buffer.lines.deleteRange(buffer.selection.start!, buffer.selection.end!);
      buffer.selection.clear();
      buffer.setCursorPosition(
        newCursorPosition!.line,
        newCursorPosition.column,
      );
      return;
    }
    if (buffer.cursor.column == 0 && buffer.cursor.line > 0) {
      final previousLine = buffer.lines[buffer.cursor.line - 1];
      final currentLine = buffer.lines[buffer.cursor.line];
      buffer.lines[buffer.cursor.line - 1] = previousLine + currentLine;
      buffer.lines.removeAt(buffer.cursor.line);
      buffer.setCursorPosition(buffer.cursor.line - 1, previousLine.length);
      return;
    }
    buffer.lines.deleteRange(
      buffer.cursor,
      CursorPosition(buffer.cursor.line, buffer.cursor.column - 1),
    );
    buffer.setCursorPosition(buffer.cursor.line, buffer.cursor.column - 1);
  }

  int clampPosition(int pos, String line) {
    if (line.isEmpty) return 0;
    if (pos < 0) return 0;
    if (pos >= line.length) return line.length;
    return pos;
  }

  void moveLeft({bool selecting = false}) {
    final newPos = CursorPosition(
      buffer.cursor.line,
      buffer.cursor.column > 0 ? buffer.cursor.column - 1 : 0,
    );
    if (selecting) {
      _extendSelection(newPos);
    } else {
      buffer.selection.clear();
      buffer.setCursorPosition(newPos.line, newPos.column);
    }
  }

  void moveRight({bool selecting = false}) {
    final line = buffer.lines[buffer.cursor.line];
    final newPos = CursorPosition(
      buffer.cursor.line,
      buffer.cursor.column < line.length
          ? buffer.cursor.column + 1
          : line.length,
    );
    if (selecting) {
      _extendSelection(newPos);
    } else {
      buffer.selection.clear();
      buffer.setCursorPosition(newPos.line, newPos.column);
    }
  }

  void moveUp({bool selecting = false}) {
    final newLine = buffer.cursor.line > 0 ? buffer.cursor.line - 1 : 0;
    final newCol = clampPosition(buffer.cursor.column, buffer.lines[newLine]);
    final newPos = CursorPosition(newLine, newCol);
    if (selecting) {
      _extendSelection(newPos);
    } else {
      buffer.selection.clear();
      buffer.setCursorPosition(newPos.line, newPos.column);
    }
  }

  void moveDown({bool selecting = false}) {
    final newLine =
        buffer.cursor.line < buffer.lines.length - 1
            ? buffer.cursor.line + 1
            : buffer.lines.length - 1;
    final newCol = clampPosition(buffer.cursor.column, buffer.lines[newLine]);
    final newPos = CursorPosition(newLine, newCol);
    if (selecting) {
      _extendSelection(newPos);
    } else {
      buffer.selection.clear();
      buffer.setCursorPosition(newPos.line, newPos.column);
    }
  }

  /// Extends the current selection or starts a new one.
  void _extendSelection(CursorPosition newPos) {
    final start = buffer.selection.start ?? buffer.cursor;
    final end = newPos;

    buffer.setSelection(Selection(start: start, end: end));
    buffer.setCursorPosition(newPos.line, newPos.column);
  }
}
