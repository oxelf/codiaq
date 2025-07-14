import 'package:codiaq_editor/src/window/window.dart';
import 'package:flutter/services.dart';

import '../../codiaq_editor.dart';

enum VimMode { normal, insert, visual }

class VimAdapter {
  final Buffer buffer;
  VimMode mode = VimMode.normal;
  bool vimEnabled = false;
  VimAdapter(this.buffer);
  String command = "";

  bool get isShift =>
      HardwareKeyboard.instance.logicalKeysPressed.contains(
        LogicalKeyboardKey.shiftLeft,
      ) ||
      HardwareKeyboard.instance.logicalKeysPressed.contains(
        LogicalKeyboardKey.shiftRight,
      );

  bool get isControl =>
      HardwareKeyboard.instance.logicalKeysPressed.contains(
        LogicalKeyboardKey.controlLeft,
      ) ||
      HardwareKeyboard.instance.logicalKeysPressed.contains(
        LogicalKeyboardKey.controlRight,
      ) ||
      HardwareKeyboard.instance.logicalKeysPressed.contains(
        LogicalKeyboardKey.control,
      );

  bool get isAlt =>
      HardwareKeyboard.instance.logicalKeysPressed.contains(
        LogicalKeyboardKey.altLeft,
      ) ||
      HardwareKeyboard.instance.logicalKeysPressed.contains(
        LogicalKeyboardKey.altRight,
      ) ||
      HardwareKeyboard.instance.logicalKeysPressed.contains(
        LogicalKeyboardKey.alt,
      );

  bool get isMeta =>
      HardwareKeyboard.instance.logicalKeysPressed.contains(
        LogicalKeyboardKey.metaLeft,
      ) ||
      HardwareKeyboard.instance.logicalKeysPressed.contains(
        LogicalKeyboardKey.metaRight,
      ) ||
      HardwareKeyboard.instance.logicalKeysPressed.contains(
        LogicalKeyboardKey.meta,
      );

  bool handleEvent(KeyEvent event) {
    int? number = int.tryParse(event.character ?? '');
    if (number != null) {}
    switch (mode) {
      case VimMode.normal:
        return handleNormal(event);
      case VimMode.insert:
        // In insert mode, we don't handle key events here
        return false;
      case VimMode.visual:
        // In visual mode, we don't handle key events here
        return false;
    }
  }

  bool handleNormal(KeyEvent event) {
    switch (event.logicalKey) {
      case LogicalKeyboardKey.keyW:
        w();
        return true;
      case LogicalKeyboardKey.keyB:
        b();
        return true;
      case LogicalKeyboardKey.keyE:
        e();
        return true;
      case LogicalKeyboardKey.keyJ:
        j();
        return true;
      case LogicalKeyboardKey.keyK:
        k();
        return true;
      case LogicalKeyboardKey.keyH:
        h();
        return true;
      case LogicalKeyboardKey.keyL:
        l();
        return true;
      case LogicalKeyboardKey.keyA:
        if (isShift) {
          A();
        } else {
          a();
        }
        return true;
      case LogicalKeyboardKey.keyI:
        if (isShift) {
          I();
        } else {
          i();
        }
        return true;
      case LogicalKeyboardKey.keyO:
        if (isShift) {
          O();
        } else {
          o();
        }
        return true;
      default:
        return false; // Unhandled key in normal mode
    }
  }

  void a() {
    //enterInsert();
    //if (window.cursor.column ==
    //    window.buffer.lines[window.cursor.line].length - 1) {
    //  print("inserting space at end of line");
    //  window.buffer.lines.insertAt(
    //    window.cursor.line,
    //    window.cursor.column + 1,
    //    ' ',
    //  );
    //}
    //window.setCursorPosition(window.cursor.line, window.cursor.column + 1);
  }

  void A() {
    //enterInsert();
    //var line = window.buffer.lines[window.cursor.line];
    //window.setCursorPosition(window.cursor.line, line.length);
  }

  void o() {
    enterInsert();
    //int insertLine = (window.cursor.line + 1).clamp(
    //  0,
    //  window.buffer.lines.length + 1,
    //);
    //window.buffer.lines.insert(insertLine, " ");
    //// move cursor to the start of the new line
    //window.setCursorPosition(insertLine, 0);
  }

  void O() {
    enterInsert();
    //int insertLine = (window.cursor.line).clamp(
    //  0,
    //  window.buffer.lines.length - 1,
    //);
    //window.buffer.lines.insert(insertLine, " ");
    //// move cursor to the start of the new line
    //window.setCursorPosition(insertLine, 0);
  }

  void i() {
    // Switch to insert mode
    enterInsert();
  }

  void I() {
    enterInsert();
    //var line = window.buffer.lines[window.cursor.line];
    //if (window.cursor.column == 0) {
    //  window.buffer.lines.insertAt(
    //    window.cursor.line,
    //    window.cursor.column,
    //    ' ',
    //  );
    //}
    //window.setCursorPosition(
    //  window.cursor.line,
    //  line.length - line.trimLeft().length,
    //);
  }

  void enterInsert() {
    // Enter insert mode at the current cursor position
    mode = VimMode.insert;
    //window.buffer.events.emit("vimModeChanged", {'mode': mode});
  }

  void enterVisual() {
    // Switch to visual mode
    mode = VimMode.visual;
    //window.buffer.events.emit("vimModeChanged", {'mode': mode});
    // Set the selection start to the current cursor position
    //window.selection.start = window.cursor.clone();
    //window.selection.end = window.cursor.clone();
  }

  void u() {
    print("u pressed");
  }

  void esc() {
    // Exit insert mode and return to normal mode
    if (mode == VimMode.insert || mode == VimMode.visual) {
      mode = VimMode.normal;
      //window.buffer.events.emit("vimModeChanged", {'mode': mode});
    }
  }

  void j() {
    //if (window.cursor.line < window.buffer.lines.length - 1) {
    //  window.moveCursorDown();
    //}
    // Already at the last line, do nothing
  }

  void k() {
    //if (window.cursor.line > 0) {
    //  window.moveCursorUp();
    //}
    // Already at the first line, do nothing
  }

  void h() {
    //if (window.cursor.column > 0) {
    //  window.moveCursorLeft();
    //}
    // Already at the start of the line, do nothing
  }

  void l() {
    //final currentLine = window.buffer.lines[window.cursor.line];
    //if (window.cursor.column < currentLine.length - 1) {
    //  window.moveCursorRight();
    //}
    // Already at the end of the line, do nothing
  }

  void w() {
    //final lines = window.buffer.lines;
    //final startLine = window.cursor.line;
    //final startCol = window.cursor.column;
    //var lineIndex = startLine;
    //var moved = false;
    //
    //while (lineIndex < lines.length) {
    //  final line = lines[lineIndex];
    //  int pos;
    //
    //  if (lineIndex == startLine) {
    //    // On initial line: start just _after_ the cursor
    //    pos = startCol + 1;
    //
    //    // 1) skip any non-spaces (rest of current word)
    //    while (pos < line.length && !RegExp(r'\s').hasMatch(line[pos])) {
    //      pos++;
    //    }
    //    // 2) skip any spaces
    //    while (pos < line.length && RegExp(r'\s').hasMatch(line[pos])) {
    //      pos++;
    //    }
    //
    //    if (pos < line.length) {
    //      // Found next word on the same line
    //      window.setCursorPosition(lineIndex, pos);
    //      moved = true;
    //      break;
    //    }
    //    // else fall through to next line
    //  } else {
    //    // On a subsequent line: land on its first non-space
    //    pos = 0;
    //    while (pos < line.length && RegExp(r'\s').hasMatch(line[pos])) {
    //      pos++;
    //    }
    //    if (pos < line.length) {
    //      window.setCursorPosition(lineIndex, pos);
    //      moved = true;
    //      break;
    //    }
    //    // else empty or all spaces → keep going
    //  }
    //
    //  lineIndex++;
    //}
    //
    //if (!moved) {
    //  // No more words anywhere → go to end of buffer
    //  final last = lines.length - 1;
    //  window.setCursorPosition(last, lines[last].length);
    //}
  }

  void b() {
    //var lineIndex = window.cursor.line;
    //var pos = window.cursor.column - 1;
    //
    //while (lineIndex >= 0) {
    //  final line = window.buffer.lines[lineIndex];
    //
    //  // Start scanning backward from pos
    //  while (pos >= 0) {
    //    // Find first non-space going backward
    //    if (!RegExp(r'\s').hasMatch(line[pos])) {
    //      // Found a non-space char, now move backward to start of this word
    //      while (pos > 0 && !RegExp(r'\s').hasMatch(line[pos - 1])) {
    //        pos--;
    //      }
    //      window.setCursorPosition(lineIndex, pos);
    //      return;
    //    }
    //    pos--;
    //  }
    //
    //  // If reached here, no word start found on this line before cursor
    //  // Move to previous line, start at its last character
    //  lineIndex--;
    //  if (lineIndex >= 0) {
    //    pos = window.buffer.lines[lineIndex].length - 1;
    //  }
    //}
    //
    //// If no previous word found at all, set cursor to start of buffer
    //window.setCursorPosition(0, 0);
  }

  void e() {
    //final lines = window.buffer.lines;
    //int lineIndex = window.cursor.line;
    //int pos = window.cursor.column;
    //bool moved = false;
    //
    //String line = lines[lineIndex];
    //
    //// Check if we are at end of a word already
    //if (pos < line.length &&
    //    !RegExp(r'\s').hasMatch(line[pos]) && // current char is non-space
    //    (pos == line.length - 1 || RegExp(r'\s').hasMatch(line[pos + 1]))) {
    //  // Move pos forward by one to skip this word's end before searching
    //  pos++;
    //}
    //
    //while (lineIndex < lines.length) {
    //  line = lines[lineIndex];
    //
    //  // Find start of next word (non-space)
    //  while (pos < line.length) {
    //    if (!RegExp(r'\s').hasMatch(line[pos])) {
    //      // Move to end of this word
    //      while (pos + 1 < line.length &&
    //          !RegExp(r'\s').hasMatch(line[pos + 1])) {
    //        pos++;
    //      }
    //      window.setCursorPosition(lineIndex, pos);
    //      moved = true;
    //      break;
    //    }
    //    pos++;
    //  }
    //
    //  if (moved) break;
    //
    //  lineIndex++;
    //  pos = 0;
    //}
    //
    //if (!moved) {
    //  // No more words → move to last char of last line
    //  final lastLine = lines.length - 1;
    //  window.setCursorPosition(lastLine, lines[lastLine].length - 1);
    //}
  }
}
