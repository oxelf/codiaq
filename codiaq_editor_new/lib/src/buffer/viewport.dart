import 'package:codiaq_editor/src/buffer/popup.dart';
import 'package:flutter/painting.dart';

import '../window/cursor.dart';
import 'buffer.dart';
import 'event.dart';

class BufferViewport {
  final Buffer buffer;
  int topLine; // line number of topmost visible line
  int height; // number of visible lines
  double pixelHeight = 0.0;
  double pixelWidth = 0.0;
  double scrollOffsetY = 0.0; // vertical scroll offset in pixels
  double scrollOffsetX = 0.0; // horizontal scroll offset in pixels
  double scrollSpeed = 1.0; // speed of scrolling in pixels per line
  double charWidth = 12;
  double lineHeight = 20;
  double textHeightFactor = 1.0;

  void setScrollOffsetY(double value) {
    scrollOffsetY = value.clamp(0.0, double.infinity);
    buffer.events.emit(BufferEventType.viewportChanged.index, {
      'topLine': topLine,
      'height': height,
      'scrollOffsetY': scrollOffsetY,
    });
  }

  void setScrollOffsetX(double value) {
    scrollOffsetX = value.clamp(0.0, double.infinity);
    buffer.events.emit(BufferEventType.viewportChanged.index, {
      'topLine': topLine,
      'height': height,
      'scrollOffsetX': scrollOffsetX,
    });
  }

  void setTopLine(int newTopLine) {
    topLine = newTopLine.clamp(0, 1 << 30);
    buffer.events.emit(BufferEventType.viewportChanged.index, {
      'topLine': topLine,
      'height': height,
    });
  }

  void setHeight(int newHeight) {
    height = newHeight.clamp(1, 1 << 30);
    buffer.events.emit(BufferEventType.viewportChanged.index, {
      'topLine': topLine,
      'height': height,
    });
  }

  BufferViewport(this.buffer, this.topLine, this.height);

  void scroll(int lines) {
    topLine = (topLine + lines).clamp(0, 1 << 30);
    buffer.events.emit(BufferEventType.viewportChanged.index, {
      'topLine': topLine,
      'height': height,
    });
  }

  void revealPos(int line, int column) {
    final newTopLine = (line - height ~/ 2).clamp(0, 1 << 30);
    if (newTopLine != topLine) {
      topLine = newTopLine;
      buffer.events.emit(BufferEventType.viewportChanged.index, {
        'topLine': topLine,
        'height': height,
      });
    }
  }

  List<String> getVisibleLines() {
    final end = (topLine + height).clamp(0, buffer.lines.length);
    return buffer.lines.getLines(topLine, end);
  }

  double getTextWidth(String text) {
    return text.length * charWidth;
  }

  double getFontSize() {
    return buffer.theme.baseStyle.fontSize ?? 16;
  }

  void computeSizes() {
    var fontSize = getFontSize();
    lineHeight = fontSize + 4;

    textHeightFactor = lineHeight / fontSize;

    var textStyle = buffer.theme.baseStyle.copyWith(
      fontSize: fontSize,
      height: textHeightFactor,
    );

    final tp = TextPainter(
      text: TextSpan(text: ' ', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    charWidth = tp.width;

    if (pixelHeight.isInfinite) {
      height = (lineHeight * buffer.lines.length).ceil();
    } else {
      height = (pixelHeight / lineHeight).ceil();
    }
  }

  /// returns the cursor position at the given offset
  /// commonly used for mouse events such as hover or click
  /// if clamp is set to true, the position will be clamped to the visible range
  /// meaning that if the position is not in the visible range, it will return the closest valid position
  CursorPosition posFromOffset(Offset offset, {bool clamp = true}) {
    final lineIndex = ((offset.dy + scrollOffsetY) / lineHeight).floor();
    if (lineIndex < 0 || lineIndex >= height) {
      return CursorPosition(0, 0); // out of visible range
    }

    final line = topLine + lineIndex;
    if (line < 0 || line >= buffer.lines.length) {
      return CursorPosition(0, 0); // out of buffer range
    }

    final lineText = buffer.lines.get(line);
    final col = ((offset.dx + scrollOffsetX) / charWidth).floor();
    final clampedCol = clamp ? col.clamp(0, lineText.length) : col;

    return CursorPosition(line, clampedCol);
  }

  bool posIsInText(CursorPosition pos) {
    if (pos.line < topLine || pos.line >= topLine + height) {
      return false; // out of visible range
    }
    if (pos.line < 0 || pos.line >= buffer.lines.length) {
      return false; // out of buffer range
    }
    final lineText = buffer.lines.get(pos.line);
    return pos.column >= 0 && pos.column <= lineText.length;
  }

  double getGutterWidth() {
    if (buffer.theme.showGutter == false) {
      return 0.0; // no gutter if not enabled
    }
    final maxLineNumber = buffer.lines.length;
    final digitCount = maxLineNumber.toString().length;
    return (digitCount + 1) * charWidth + buffer.theme.gutterRightSize;
  }

  /// Converts a CursorPosition to an Offset based on the viewport's scroll offsets and character dimensions.
  /// This is only used for rendering purposes, such as positioning popups or tooltips.
  Offset positionFromCursorPos(CursorPosition pos) {
    if (pos.line < topLine || pos.line >= topLine + height) {
      return Offset(0, 0); // out of visible range
    }

    final lineIndex = pos.line - topLine;
    final x = pos.column * charWidth + scrollOffsetX;
    final y = lineIndex * lineHeight + scrollOffsetY;

    return Offset(x, y);
  }
}
