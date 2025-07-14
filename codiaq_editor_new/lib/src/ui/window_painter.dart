//import 'package:codiaq_editor/codiaq_editor.dart';
//import 'package:codiaq_editor/src/buffer/lines.dart';
//import 'package:codiaq_editor/src/buffer/popup.dart';
//import 'package:codiaq_editor/src/window/controller.dart';
//import 'package:flutter/material.dart';
//import 'package:flutter/widgets.dart';
//import "../window/viewport.dart" as vp;
//
//class WindowPainter extends CustomPainter {
//  final Window window;
//  EditorTheme theme;
//
//  late final double fontSize;
//  late final double lineHeight;
//  late final double charWidth;
//  late final TextStyle textStyle;
//  late final double heightFactor;
//
//  WindowPainter(this.window, this.theme, {TextStyle? style}) {
//    fontSize = theme.baseStyle.fontSize ?? 16.0;
//    lineHeight = fontSize + 4;
//
//    heightFactor = lineHeight / fontSize;
//    textStyle = theme.baseStyle.copyWith(
//      fontSize: fontSize,
//      height: heightFactor,
//    );
//
//    final tp = TextPainter(
//      text: TextSpan(text: ' ', style: textStyle),
//      textDirection: TextDirection.ltr,
//    )..layout();
//    charWidth = tp.width;
//  }
//
//  @override
//  void paint(Canvas canvas, Size size) {
//    print("WINDOW PAINTING");
//    var startTime = DateTime.now();
//    final selection = window.selection;
//    final buffer = window.buffer;
//    final viewport = window.viewport;
//    final visibleLines = buffer.getLinesInViewport(viewport);
//
//    final scrollX = viewport.scrollOffsetX;
//    final scrollY = viewport.scrollOffsetY;
//
//    final bgPaint = Paint()..color = theme.backgroundColor;
//    canvas.drawRect(Offset.zero & size, bgPaint);
//
//    for (int i = 0; i < visibleLines.length; i++) {
//      final y = i * lineHeight - scrollY;
//      if (y + lineHeight < 0 || y > size.height) continue;
//
//      final line = visibleLines[i];
//      final lineNumber = viewport.topLine + i;
//
//      final isCursorLine = (window.cursor.line == lineNumber);
//      final highlightPaint =
//          Paint()
//            ..color =
//                (isCursorLine)
//                    ? theme.lineHighlightColor
//                    : theme.backgroundColor;
//      canvas.drawRect(
//        Rect.fromLTWH(-scrollX, y, size.width + scrollX.abs(), lineHeight),
//        highlightPaint,
//      );
//      if (selection.isActive) {
//        _drawSelectionForLine(
//          canvas,
//          line,
//          lineNumber,
//          y,
//          selection,
//          scrollX,
//          size,
//        );
//      }
//
//      _drawLineText(canvas, line, lineNumber, y, scrollX);
//      if (line.length > (window.cursor.column + 1) &&
//          isCursorLine &&
//          isBracket(line[window.cursor.column])) {
//        print(
//          "Drawing closing bracket for cursor at $lineNumber:${window.cursor.column}",
//        );
//        try {
//          final closingBracket = buffer.lines.findClosingBracket(window.cursor);
//          if (closingBracket != null) {
//            final (x, y) = positionFromCursorPos(closingBracket);
//            // draw a box around the closing bracket, with an opacity of 0.3
//            // it should be filled with a light grey color
//            canvas.drawRect(
//              Rect.fromLTWH(x - 3, y, charWidth, lineHeight),
//              Paint()
//                ..color = Colors.grey.withOpacity(0.5)
//                ..style = PaintingStyle.fill
//                ..strokeWidth = 1.5,
//            );
//          }
//        } catch (e) {
//          // Ignore errors finding closing bracket
//        }
//      }
//      _drawDiagnostics(
//        canvas,
//        line,
//        lineNumber,
//        y,
//        window.diagnostics,
//        scrollX,
//      );
//
//      if (window.focusNode.hasFocus) {
//        _drawCursor(canvas, lineNumber, y, scrollX);
//      }
//    }
//    print(
//      "painting took ${DateTime.now().difference(startTime).inMilliseconds}ms",
//    );
//  }
//
//  void _drawSelectionForLine(
//    Canvas canvas,
//    String lineText,
//    int lineNumber,
//    double y,
//    Selection selection,
//    double scrollX,
//    Size size,
//  ) {
//    final start = selection.start!;
//    final end = selection.end!;
//
//    // Normalize selection start/end
//    final isForward =
//        (start.line < end.line) ||
//        (start.line == end.line && start.column <= end.column);
//    final selStart = isForward ? start : end;
//    final selEnd = isForward ? end : start;
//
//    if (lineNumber < selStart.line || lineNumber > selEnd.line) {
//      return; // Not in selection
//    }
//
//    int selStartCol = 0;
//    int selEndCol = lineText.length;
//
//    if (lineNumber == selStart.line) {
//      selStartCol = selStart.column.clamp(0, lineText.length);
//    }
//    if (lineNumber == selEnd.line) {
//      selEndCol = selEnd.column.clamp(0, lineText.length);
//    }
//
//    if (selStartCol >= selEndCol) {
//      return; // Nothing to draw
//    }
//
//    final xStart =
//        _measureTextWidth(lineText.substring(0, selStartCol)) - scrollX;
//    double xEnd = _measureTextWidth(lineText.substring(0, selEndCol)) - scrollX;
//
//    bool extendToEnd = false;
//    if (selection.start!.line != selection.end!.line) {
//      if (lineNumber != selEnd.line) extendToEnd = true;
//    }
//    if (extendToEnd) {
//      xEnd = size.width + scrollX.abs();
//    }
//
//    final paint = Paint()..color = theme.selectionColor;
//    canvas.drawRect(Rect.fromLTWH(xStart, y, xEnd - xStart, lineHeight), paint);
//
//    // Draw mobile selection handles if enabled
//    if (window.isMobile) {
//      final handlePaint =
//          Paint()..color = const Color(0xFF007AFF); // iOS blue color
//      final double handleRadius = 6.0;
//
//      if (lineNumber == selStart.line) {
//        canvas.drawCircle(
//          Offset(xStart, y + lineHeight),
//          handleRadius,
//          handlePaint,
//        );
//      }
//      if (lineNumber == selEnd.line) {
//        canvas.drawCircle(
//          Offset(xEnd, y + lineHeight),
//          handleRadius,
//          handlePaint,
//        );
//      }
//    }
//  }
//
//  void _drawLineText(
//    Canvas canvas,
//    String line,
//    int lineNumber,
//    double y,
//    double scrollX,
//  ) {
//    try {
//      final spans = getHighlightSpansForLine(lineNumber, line);
//      final textPainter = TextPainter(
//        text: TextSpan(style: textStyle, children: spans),
//        textDirection: TextDirection.ltr,
//      )..layout();
//
//      textPainter.paint(canvas, Offset(-scrollX, y));
//    } catch (e) {
//      print("Error drawing line $lineNumber: $e");
//      // Fallback to plain text if there's an error
//      final textPainter = TextPainter(
//        text: TextSpan(text: line, style: textStyle),
//        textDirection: TextDirection.ltr,
//      )..layout();
//      textPainter.paint(canvas, Offset(-scrollX, y));
//    }
//  }
//
//  List<InlineSpan> getHighlightSpansForLine(int lineNumber, String line) {
//    final highlights = window.buffer.highlights.getHighlightsForLine(
//      lineNumber,
//    );
//    int i = 0;
//    String currentText = '';
//    List<TextSpan> spans = [];
//
//    Highlight? hasHighlightAt(int index) {
//      int h = highlights.indexWhere((h) => h.startCol == index);
//      if (h >= 0) {
//        return highlights[h];
//      }
//      return null;
//    }
//
//    // --- FIX for "Bad state: no element" error ---
//    HighlightGroup? getHighlightGroup(int start, int end) {
//      List<Highlight> relevantHighlights =
//          highlights
//              .where(
//                (h) =>
//                    h.line == lineNumber &&
//                    h.startCol < end &&
//                    h.endCol > start,
//              )
//              .toList();
//      if (relevantHighlights.isEmpty) {
//        return null;
//      }
//
//      final groups =
//          relevantHighlights
//              .map((h) => window.buffer.highlightGroups.get(h.group))
//              .whereType<HighlightGroup>()
//              .toList();
//
//      if (groups.isEmpty) {
//        return null;
//      }
//
//      return groups.reduce((a, b) => a.priority > b.priority ? a : b);
//    }
//
//    // --- Refactored loop for improved resiliency ---
//    while (i < line.length) {
//      final highlight = hasHighlightAt(i);
//
//      if (highlight != null) {
//        // Clamp the highlight's end column to be within the line's bounds.
//        final safeEndCol = highlight.endCol.clamp(i, line.length);
//
//        // Ensure the highlight range is valid and non-empty.
//        if (safeEndCol > i) {
//          // If there's any pending un-highlighted text, add it first.
//          if (currentText.isNotEmpty) {
//            spans.add(TextSpan(text: currentText, style: textStyle));
//            currentText = '';
//          }
//
//          // Create and add the highlighted text span.
//          final text = line.substring(i, safeEndCol);
//          final highlightGroup = getHighlightGroup(i, safeEndCol);
//          TextStyle mergedStyle = textStyle;
//          if (highlightGroup != null) {
//            mergedStyle = mergedStyle.copyWith(
//              color: highlightGroup.textColor,
//              backgroundColor: highlightGroup.backgroundColor,
//            );
//          }
//          spans.add(TextSpan(text: text, style: mergedStyle));
//
//          // Move the index to the end of the processed highlight.
//          i = safeEndCol;
//          continue;
//        }
//      }
//
//      // If there was no highlight or the highlight was invalid,
//      // process the current character as normal text.
//      currentText += line[i];
//      i++;
//    }
//
//    // Add any remaining un-highlighted text at the end of the line.
//    if (currentText.isNotEmpty) {
//      spans.add(TextSpan(text: currentText, style: textStyle));
//    }
//
//    return spans;
//  }
//
//  void _drawDiagnostics(
//    Canvas canvas,
//    String line,
//    int lineNumber,
//    double y,
//    DiagnosticManager diagnostics,
//    double scrollX,
//  ) {
//    final diags = diagnostics.diagnosticsForLine(lineNumber);
//    for (final diag in diags) {
//      final paint =
//          Paint()
//            ..color = _colorForSeverity(diag.severity)
//            ..strokeWidth = 1.5;
//
//      final clampedEnd = diag.endCol.clamp(0, line.length);
//      final xStart =
//          (diag.startCol <= 0 || diag.startCol >= line.length)
//              ? 0.0
//              : _measureTextWidth(line.substring(0, diag.startCol)) - scrollX;
//      final xEnd =
//          (clampedEnd >= line.length)
//              ? 0
//              : _measureTextWidth(line.substring(0, clampedEnd)) - scrollX;
//
//      final baseY = y + lineHeight - 4;
//
//      for (double x = xStart; x < xEnd; x += 4) {
//        canvas.drawLine(Offset(x, baseY + 1), Offset(x + 2, baseY + 3), paint);
//        canvas.drawLine(
//          Offset(x + 2, baseY + 4),
//          Offset(x + 4, baseY + 1),
//          paint,
//        );
//      }
//    }
//  }
//
//  void _drawCursor(Canvas canvas, int lineNumber, double y, double scrollX) {
//    final cursor = window.cursor;
//
//    var cursorStyle =
//        (!window.vim.vimEnabled)
//            ? theme.cursorStyle
//            : theme.vimCursorStyles[window.vim.mode] ?? theme.cursorStyle;
//    if (cursor.line != lineNumber) return;
//
//    final lineText =
//        window.buffer.getLinesInViewport(window.viewport)[lineNumber -
//            window.viewport.topLine];
//    final col = (cursor.column).clamp(0, lineText.length);
//    final x = _measureTextWidth(lineText.substring(0, col)) - scrollX;
//
//    double width;
//    Color cursorColor = theme.cursorColor;
//
//    if (cursorStyle == CursorStyle.line) {
//      width = 2;
//    } else {
//      width = charWidth; // Use the pre-calculated character width
//      cursorColor = theme.cursorColor.withOpacity(0.3);
//    }
//
//    canvas.drawRect(
//      Rect.fromLTWH(x, y, width, lineHeight),
//      Paint()..color = cursorColor, // Use the correct color for block/line
//    );
//  }
//
//  double _measureTextWidth(String text) {
//    return text.length * charWidth;
//  }
//
//  Color _colorForSeverity(DiagnosticSeverity severity) {
//    return theme.diagnosticSeverityColors[severity] ??
//        Color(0xFFCCCCCC); // Default color if not defined
//  }
//
//  (int line, int col) computeTapPosition(Offset localOffset) {
//    var startTime = DateTime.now();
//    final scrollX = window.viewport.scrollOffsetX;
//    final scrollY = window.viewport.scrollOffsetY;
//
//    final tappedLine =
//        (localOffset.dy + scrollY) ~/ lineHeight + window.viewport.topLine;
//    final lines = window.buffer.getLinesInViewport(window.viewport);
//
//    final clampedLineIndex = (tappedLine - window.viewport.topLine).clamp(
//      0,
//      lines.length,
//    );
//    final actualLineNumber = clampedLineIndex + window.viewport.topLine;
//    final lineText = lines.isNotEmpty ? lines[clampedLineIndex] : '';
//
//    final col = computeColFromOffset(lineText, localOffset.dx + scrollX);
//    print(
//      "position computing took ${DateTime.now().difference(startTime).inMilliseconds}ms",
//    );
//    return (actualLineNumber, col);
//  }
//
//  (double x, double y) positionFromCursorPos(CursorPosition pos) {
//    final scrollX = window.viewport.scrollOffsetX;
//    final scrollY = window.viewport.scrollOffsetY;
//
//    final lines = window.buffer.getLinesInViewport(window.viewport);
//    if (pos.line < window.viewport.topLine ||
//        pos.line >= window.viewport.topLine + lines.length) {
//      return (0, 0); // Out of viewport
//    }
//
//    final lineIndex = pos.line - window.viewport.topLine;
//    print("col is ${pos.column} for line: $lineIndex");
//    final lineText = lines[lineIndex];
//
//    final col =
//        (pos.column <= 0)
//            ? 0
//            : (pos.column >= lineText.length)
//            ? lineText.length - 1
//            : pos.column;
//    if (col <= 0) {
//      return (0, lineIndex * lineHeight - scrollY);
//    }
//
//    final x = _measureTextWidth(lineText.substring(0, col)) - scrollX;
//    final y = lineIndex * lineHeight - scrollY;
//
//    return (x, y);
//  }
//
//  (int line, int col)? tryComputeTapPosition(Offset localOffset) {
//    final scrollX = window.viewport.scrollOffsetX;
//    final scrollY = window.viewport.scrollOffsetY;
//
//    final tappedLine =
//        (localOffset.dy + scrollY) ~/ lineHeight + window.viewport.topLine;
//    final lines = window.buffer.getLinesInViewport(window.viewport);
//
//    final clampedLineIndex = (tappedLine - window.viewport.topLine);
//    if (clampedLineIndex < 0 || clampedLineIndex >= lines.length) {
//      return null; // Tap is outside the visible lines
//    }
//    final actualLineNumber = clampedLineIndex + window.viewport.topLine;
//    final lineText = lines.isNotEmpty ? lines[clampedLineIndex] : '';
//
//    final col = tryComputeColFromOffset(lineText, localOffset.dx + scrollX);
//    if (col == null) {
//      return null; // Unable to compute column
//    }
//    return (actualLineNumber, col);
//  }
//
//  int getWidthForLine(String lineText) {
//    final tp = TextPainter(
//      text: TextSpan(text: lineText, style: textStyle),
//      textDirection: TextDirection.ltr,
//    )..layout();
//    return tp.width.round();
//  }
//
//  int? tryComputeColFromOffset(String lineText, double dx) {
//    if (lineText.isEmpty)
//      return 0; // Or null if you truly want null for empty line
//
//    final col = (dx / charWidth).round();
//    if (col >= 0 && col <= lineText.length) {
//      return col;
//    }
//    return null;
//  }
//
//  int computeColFromOffset(String lineText, double dx) {
//    if (lineText.isEmpty) return 0;
//    // Divide dx by charWidth and round to nearest character index
//    return (dx / charWidth).round().clamp(0, lineText.length);
//  }
//
//  @override
//  bool shouldRepaint(covariant WindowPainter oldDelegate) {
//    return oldDelegate.window != window || oldDelegate.theme != theme;
//  }
//}
