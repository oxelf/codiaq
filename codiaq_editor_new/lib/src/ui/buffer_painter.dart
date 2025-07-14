import 'package:flutter/rendering.dart';

import '../../codiaq_editor.dart';
import '../window/controller.dart';
import '../window/selection.dart';

class BufferPainter extends CustomPainter {
  final Buffer buffer;

  BufferPainter(this.buffer);

  @override
  void paint(Canvas canvas, Size size) {
    //print("Painting buffer: ${buffer.path} (${buffer.lines.length} lines)");
    final bgPaint = Paint()..color = buffer.theme.backgroundColor;
    canvas.drawRect(Offset.zero & size, bgPaint);

    var visibleLines = buffer.viewport.getVisibleLines();
    var lineHeight = buffer.viewport.lineHeight;
    var scrollY = buffer.viewport.scrollOffsetY;
    var scrollX = buffer.viewport.scrollOffsetX;
    var topLine = buffer.viewport.topLine;
    var selection = buffer.selection;
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    var textStyle = buffer.theme.baseStyle.copyWith(
      fontSize: buffer.viewport.getFontSize(),
      height: buffer.viewport.textHeightFactor,
    );

    for (int i = 0; i < visibleLines.length; i++) {
      final y = i * lineHeight - scrollY;
      if (y + lineHeight < 0 || y > size.height) continue;

      final line = visibleLines[i];
      final lineNumber = topLine + i;

      final isCursorLine = (buffer.cursor.line == lineNumber);
      if (isCursorLine) {
        final highlightPaint = Paint()..color = buffer.theme.lineHighlightColor;
        canvas.drawRect(
          Rect.fromLTWH(-scrollX, y, size.width + scrollX.abs(), lineHeight),
          highlightPaint,
        );
      }

      if (selection.isActive) {
        _drawSelectionForLine(
          canvas,
          line,
          lineNumber,
          y,
          selection,
          scrollX,
          size,
        );
      }
      _drawLineText(canvas, line, lineNumber, y, scrollX, textStyle);

      _drawDiagnostics(
        canvas,
        line,
        lineNumber,
        y,
        buffer.diagnostics,
        scrollX,
      );

      if (buffer.focusNode.hasFocus) {
        _drawCursor(canvas, lineNumber, y, scrollX);
      }
    }
  }

  void _drawLineText(
    Canvas canvas,
    String line,
    int lineNumber,
    double y,
    double scrollX,
    TextStyle textStyle,
  ) {
    try {
      final spans = getHighlightSpansForLine(lineNumber, line, textStyle);
      final textPainter = TextPainter(
        text: TextSpan(style: textStyle, children: spans),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(canvas, Offset(-scrollX, y));
    } catch (e) {
      print("Error drawing line $lineNumber: $e");
      // Fallback to plain text if there's an error
      final textPainter = TextPainter(
        text: TextSpan(text: line, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(-scrollX, y));
    }
  }

  void _drawCursor(Canvas canvas, int lineNumber, double y, double scrollX) {
    final cursor = buffer.cursor;

    var cursorStyle = buffer.theme.cursorStyle;
    if (cursor.line != lineNumber) return;

    final lineText =
        buffer.viewport.getVisibleLines()[lineNumber - buffer.viewport.topLine];
    final col = (cursor.column).clamp(0, lineText.length);
    final x =
        buffer.viewport.getTextWidth(lineText.substring(0, col)) - scrollX;

    double width;
    Color cursorColor = buffer.theme.cursorColor;

    if (cursorStyle == CursorStyle.line) {
      width = 2;
    } else {
      width = buffer.viewport.charWidth;
      cursorColor = buffer.theme.cursorColor.withOpacity(0.3);
    }

    canvas.drawRect(
      Rect.fromLTWH(x, y, width, buffer.viewport.lineHeight),
      Paint()..color = cursorColor,
    );
  }

  void _drawSelectionForLine(
    Canvas canvas,
    String lineText,
    int lineNumber,
    double y,
    Selection selection,
    double scrollX,
    Size size,
  ) {
    final start = selection.start!;
    final end = selection.end!;

    // Normalize selection start/end
    final isForward =
        (start.line < end.line) ||
        (start.line == end.line && start.column <= end.column);
    final selStart = isForward ? start : end;
    final selEnd = isForward ? end : start;

    if (lineNumber < selStart.line || lineNumber > selEnd.line) {
      return; // Not in selection
    }

    int selStartCol = 0;
    int selEndCol = lineText.length;

    if (lineNumber == selStart.line) {
      selStartCol = selStart.column.clamp(0, lineText.length);
    }
    if (lineNumber == selEnd.line) {
      selEndCol = selEnd.column.clamp(0, lineText.length);
    }

    if (selStartCol >= selEndCol && lineText.isNotEmpty) {
      return; // Nothing to draw
    }

    final xStart =
        buffer.viewport.getTextWidth(lineText.substring(0, selStartCol)) -
        scrollX;
    double xEnd =
        buffer.viewport.getTextWidth(lineText.substring(0, selEndCol)) -
        scrollX;

    bool extendToEnd = false;
    if (selection.start!.line != selection.end!.line) {
      if (lineNumber != selEnd.line) extendToEnd = true;
    }
    if (extendToEnd) {
      xEnd = size.width + scrollX.abs();
    }

    final paint = Paint()..color = buffer.theme.selectionColor;
    canvas.drawRect(
      Rect.fromLTWH(xStart, y, xEnd - xStart, buffer.viewport.lineHeight),
      paint,
    );

    // Draw mobile selection handles if enabled
    //if (window.isMobile) {
    //  final handlePaint =
    //      Paint()..color = const Color(0xFF007AFF); // iOS blue color
    //  final double handleRadius = 6.0;
    //
    //  if (lineNumber == selStart.line) {
    //    canvas.drawCircle(
    //      Offset(xStart, y + lineHeight),
    //      handleRadius,
    //      handlePaint,
    //    );
    //  }
    //  if (lineNumber == selEnd.line) {
    //    canvas.drawCircle(
    //      Offset(xEnd, y + lineHeight),
    //      handleRadius,
    //      handlePaint,
    //    );
    //  }
    //}
  }

  List<InlineSpan> getHighlightSpansForLine(
    int lineNumber,
    String line,
    TextStyle textStyle,
  ) {
    final highlights = buffer.highlights.getHighlightsForLine(lineNumber);
    int i = 0;
    String currentText = '';
    List<TextSpan> spans = [];

    Highlight? hasHighlightAt(int index) {
      int h = highlights.indexWhere((h) => h.startCol == index);
      if (h >= 0) {
        return highlights[h];
      }
      return null;
    }

    HighlightGroup? getHighlightGroup(int start, int end) {
      List<Highlight> relevantHighlights =
          highlights
              .where(
                (h) =>
                    h.line == lineNumber &&
                    h.startCol < end &&
                    h.endCol > start,
              )
              .toList();
      if (relevantHighlights.isEmpty) {
        return null;
      }

      final groups =
          relevantHighlights
              .map((h) => buffer.highlightGroups.get(h.group))
              .whereType<HighlightGroup>()
              .toList();

      if (groups.isEmpty) {
        return null;
      }

      return groups.reduce((a, b) => a.priority > b.priority ? a : b);
    }

    while (i < line.length) {
      final highlight = hasHighlightAt(i);

      if (highlight != null) {
        final safeEndCol = highlight.endCol.clamp(i, line.length);

        if (safeEndCol > i) {
          if (currentText.isNotEmpty) {
            spans.add(TextSpan(text: currentText, style: textStyle));
            currentText = '';
          }

          final text = line.substring(i, safeEndCol);
          final highlightGroup = getHighlightGroup(i, safeEndCol);
          TextStyle mergedStyle = textStyle;
          if (highlightGroup != null) {
            mergedStyle = mergedStyle.copyWith(
              color: highlightGroup.textColor,
              backgroundColor: highlightGroup.backgroundColor,
            );
          }
          spans.add(TextSpan(text: text, style: mergedStyle));

          i = safeEndCol;
          continue;
        }
      }

      currentText += line[i];
      i++;
    }

    if (currentText.isNotEmpty) {
      spans.add(TextSpan(text: currentText, style: textStyle));
    }

    return spans;
  }

  void _drawDiagnostics(
    Canvas canvas,
    String line,
    int lineNumber,
    double y,
    DiagnosticManager diagnostics,
    double scrollX,
  ) {
    final diags = diagnostics.diagnosticsForLine(lineNumber);
    for (final diag in diags) {
      final paint =
          Paint()
            ..color =
                buffer.theme.diagnosticSeverityColors[diag.severity] ??
                buffer.theme.diagnosticSeverityColors[DiagnosticSeverity
                    .information]!
            ..strokeWidth = 1.25;

      final clampedEnd = diag.endCol.clamp(0, line.length);
      final xStart =
          (diag.startCol <= 0 || diag.startCol >= line.length)
              ? 0.0
              : buffer.viewport.getTextWidth(line.substring(0, diag.startCol)) -
                  scrollX;
      final xEnd =
          (clampedEnd >= line.length)
              ? 0
              : buffer.viewport.getTextWidth(line.substring(0, clampedEnd)) -
                  scrollX;

      final baseY = y + buffer.viewport.lineHeight - 4;

      for (double x = xStart; x < xEnd; x += 6) {
        canvas.drawLine(Offset(x, baseY + 1), Offset(x + 3, baseY + 3), paint);
        canvas.drawLine(
          Offset(x + 3, baseY + 4),
          Offset(x + 6, baseY + 1),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant BufferPainter oldDelegate) {
    return oldDelegate.buffer != buffer ||
        oldDelegate.buffer.viewport != buffer.viewport ||
        oldDelegate.buffer.theme != buffer.theme ||
        oldDelegate.buffer.selection != buffer.selection;
  }
}
