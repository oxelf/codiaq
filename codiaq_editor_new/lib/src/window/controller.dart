import 'package:codiaq_editor/src/buffer/buffer.dart';

import 'cursor.dart';
import 'selection.dart';

enum EditorMode { normal, insert, visual, insertAlways }

enum CursorStyle { block, line, underline }

class EditorController {
  final Buffer buffer;
  final CursorPosition cursor = CursorPosition(0, 0);
  final Selection selection = Selection();

  EditorMode mode = EditorMode.normal;

  EditorController(this.buffer);

  void moveCursorLeft() {
    if (cursor.column > 0) {
      cursor.column--;
    }
  }

  void moveCursorRight() {
    final line = buffer.getLines()[cursor.line];
    if (cursor.column < line.length) {
      cursor.column++;
    }
  }

  void moveCursorUp() {
    if (cursor.line > 0) {
      cursor.line--;
      _clampColumn();
    }
  }

  void moveCursorDown() {
    if (cursor.line < buffer.getLines().length - 1) {
      cursor.line++;
      _clampColumn();
    }
  }

  void _clampColumn() {
    final line = buffer.getLines()[cursor.line];
    if (cursor.column > line.length) {
      cursor.column = line.length;
    }
  }

  void enterInsertMode() {
    mode = EditorMode.insert;
  }

  void enterNormalMode() {
    mode = EditorMode.normal;
    selection.clear();
  }

  void enterVisualMode() {
    mode = EditorMode.visual;
    selection.start = CursorPosition(cursor.line, cursor.column);
    selection.end = CursorPosition(cursor.line, cursor.column);
    selection.mode = EditorMode.visual;
  }

  void deactivateVimMode() {
    mode = EditorMode.insertAlways;
  }

  void updateSelection() {
    if (mode == EditorMode.visual) {
      selection.end = CursorPosition(cursor.line, cursor.column);
    }
  }
}
