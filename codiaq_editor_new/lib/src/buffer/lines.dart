import 'package:codiaq_editor/codiaq_editor.dart';
import 'package:codiaq_editor/src/buffer/types.dart';
import 'package:flutter/widgets.dart';

import '../window/cursor.dart';

bool isBracket(String char) {
  return switch (char) {
    '(' || ')' || '{' || '}' || '[' || ']' || '<' || '>' => true,
    _ => false,
  };
}

class LineList {
  final List<String> _lines = [];
  final Buffer buffer;

  LineList(this.buffer, {List<String>? initialLines}) {
    if (initialLines != null) {
      setLines(initialLines);
    } else {
      _lines.add('');
    }
  }

  @override
  String toString() => _lines.join('\n');
  String getText() => _lines.join('\n');

  void setLines(List<String> lines) {
    _lines
      ..clear()
      ..addAll(lines);
    buffer.events.emit(BufferEventType.modified.index);
  }

  int offsetFromCursor(CursorPosition pos) {
    int offset = 0;
    for (int i = 0; i < pos.line; i++) {
      offset += _lines[i].length + 1;
    }
    return offset + pos.column;
  }

  CursorPosition cursorFromOffset(int offset) {
    int line = 0;
    while (line < _lines.length && offset > _lines[line].length) {
      offset -= _lines[line].length + 1;
      line++;
    }
    return CursorPosition(line, offset);
  }

  int get maxLineLength =>
      _lines.isEmpty
          ? 0
          : _lines.map((l) => l.length).reduce((a, b) => a > b ? a : b);

  void replaceRange(
    CursorPosition start,
    CursorPosition end,
    String newText, {
    bool silent = false,
  }) {
    var rangeBefore = getRangeText(start, end);
    deleteRange(start, end, silent: true);
    final lines = newText.split('\n');
    if (lines.length == 1) {
      insertAt(start.line, start.column, lines.first, silent: true);
    } else {
      insertAt(start.line, start.column, lines.first, silent: true);
      for (int i = 0; i < lines.length - 2; i++) {
        insert(start.line + 1 + i, lines[i + 1], silent: true);
      }
      insertAt(start.line + lines.length - 1, 0, lines.last, silent: true);
    }
    if (!silent) {
      buffer.undoTree.save(
        top: start.line,
        bot: start.line + lines.length - 1,
        before: rangeBefore.split("\n"),
        after: _lines.sublist(start.line, start.line + lines.length),
        cursorBefore: buffer.cursor,
        cursorAfter: buffer.cursor,
      );
    }
  }

  void deleteRange(
    CursorPosition start,
    CursorPosition end, {
    bool silent = false,
  }) {
    if (start.line > end.line ||
        (start.line == end.line && start.column > end.column)) {
      final tmp = start;
      start = end;
      end = tmp;
    }

    if (start.line == end.line) {
      _lines[start.line] = _lines[start.line].replaceRange(
        start.column,
        end.column,
        '',
      );
    } else {
      final mergedLine =
          _lines[start.line].substring(0, start.column) +
          _lines[end.line].substring(end.column);
      _lines[start.line] = mergedLine;
      _lines.removeRange(start.line + 1, end.line + 1);
    }

    buffer.events.emit(BufferEventType.deleted.index, {
      'startLine': start.line,
      'startCol': start.column,
      'endLine': end.line,
      'endCol': end.column,
    });

    if (!silent) {
      buffer.undoTree.save(
        top: start.line,
        bot: start.line,
        before: [],
        after: [_lines[start.line]],
        cursorBefore: buffer.cursor,
        cursorAfter: buffer.cursor,
      );
    }
  }

  void insert(int index, String line, {bool silent = false}) {
    _lines.insert(index, line);
    buffer.events.emit(BufferEventType.inserted.index, {
      'line': index,
      'text': line,
    });

    if (!silent) {
      buffer.undoTree.save(
        top: index,
        bot: index,
        before: [],
        after: [line],
        cursorBefore: buffer.cursor,
        cursorAfter: buffer.cursor,
      );
    }
  }

  void insertAt(int line, int col, String text, {bool silent = false}) {
    final currentLine = _lines[line];
    final prefix = currentLine.substring(0, col);
    final suffix = currentLine.substring(col);
    final lines = text.split('\n');

    if (lines.length == 1) {
      final newLine = prefix + text + suffix;
      _lines[line] = newLine;
      buffer.events.emit(BufferEventType.inserted.index, {
        'line': line,
        'col': col,
        'text': text,
      });
      if (!silent) {
        buffer.undoTree.save(
          top: line,
          bot: line,
          before: [currentLine],
          after: [newLine],
          cursorBefore: buffer.cursor,
          cursorAfter: buffer.cursor,
        );
      }
    } else {
      final insertedLines = <String>[];
      insertedLines.add(prefix + lines.first);
      insertedLines.addAll(lines.sublist(1, lines.length - 1));
      insertedLines.add(lines.last + suffix);

      _lines.removeAt(line);
      _lines.insertAll(line, insertedLines);

      buffer.events.emit(BufferEventType.inserted.index, {
        'line': line,
        'col': col,
        'text': text,
      });

      if (!silent) {
        buffer.undoTree.save(
          top: line,
          bot: line + insertedLines.length - 1,
          before: [currentLine],
          after: insertedLines,
          cursorBefore: buffer.cursor,
          cursorAfter: buffer.cursor,
        );
      }
    }
  }

  void removeAt(int index, {bool silent = false}) {
    _lines.removeAt(index);
    buffer.events.emit(BufferEventType.deleted.index, {'line': index});
    if (!silent) {
      buffer.undoTree.save(
        top: index,
        bot: index,
        before: [_lines[index]],
        after: [],
        cursorBefore: buffer.cursor,
        cursorAfter: buffer.cursor,
      );
    }
  }

  operator []=(int index, String line) {
    _lines[index] = line;
    buffer.undoTree.save(
      top: index,
      bot: index,
      before: [_lines[index]],
      after: [line],
      cursorBefore: buffer.cursor,
      cursorAfter: buffer.cursor,
    );
  }

  String getRangeText(CursorPosition start, CursorPosition end) {
    if (start.line > end.line ||
        (start.line == end.line && start.column > end.column)) {
      final tmp = start;
      start = end;
      end = tmp;
    }

    if (start.line == end.line) {
      return _lines[start.line].substring(start.column, end.column);
    }

    final firstLine = _lines[start.line].substring(start.column);
    final lastLine = _lines[end.line].substring(0, end.column);
    final middle = _lines.sublist(start.line + 1, end.line);
    return ([firstLine, ...middle, lastLine]).join('\n');
  }

  EditorTextRange wordAtPos(
    CursorPosition pos, {
    List<String> delimiters = const [
      ' ',
      ';',
      '(',
      ')',
      '<',
      '>',
      '{',
      '}',
      '[',
      ']',
      '"',
      "'",
    ],
  }) {
    final line = _lines[pos.line];
    int start = pos.column;
    int end = pos.column;

    while (start > 0 && !delimiters.contains(line[start - 1])) {
      start--;
    }
    while (end < line.length && !delimiters.contains(line[end])) {
      end++;
    }

    return EditorTextRange(
      start: EditorTextPosition(pos.line, start),
      end: EditorTextPosition(pos.line, end),
    );
  }

  operator [](int index) {
    if (index < 0 || index >= _lines.length) {
      throw RangeError.index(index, _lines, 'index', 'Index out of range');
    }
    return _lines[index];
  }

  String get(int index) {
    if (index < 0 || index >= _lines.length) {
      throw RangeError.index(index, _lines, 'index', 'Index out of range');
    }
    return _lines[index];
  }

  List<String> getLines(int start, int end) {
    if (start < 0 || end > _lines.length || start > end) {
      throw RangeError.range(start, 0, _lines.length, 'start');
    }
    return _lines.sublist(start, end);
  }

  List<String> snapshot() => List.from(_lines);

  int get length => _lines.length;
}
