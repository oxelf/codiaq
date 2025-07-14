import 'package:flutter/material.dart';

import '../../codiaq_editor.dart';
import 'window_painter.dart';

class GutterWidget extends StatefulWidget {
  final Buffer buffer;

  const GutterWidget({super.key, required this.buffer});

  @override
  State<GutterWidget> createState() => _GutterWidgetState();
}

class _GutterWidgetState extends State<GutterWidget> {
  int? hoveredLine;
  @override
  Widget build(BuildContext context) {
    final viewport = widget.buffer.viewport;
    final visibleLines = widget.buffer.viewport.getVisibleLines();
    final cursorLine = widget.buffer.cursor.line;
    final theme = widget.buffer.theme;
    final gutterWidth = _calculateGutterWidth();

    return Container(
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        border: Border(right: BorderSide(color: theme.dividerColor, width: 3)),
      ),
      width: gutterWidth,
      height: viewport.height * viewport.lineHeight,
      child: Stack(
        children: [
          Positioned(
            top: -viewport.scrollOffsetY,
            left: 0,
            right: 0,
            child: Column(
              children: List.generate(visibleLines.length, (i) {
                final lineNumber = viewport.topLine + i + 1;
                final isCursorLine = lineNumber - 1 == cursorLine;

                final displayNumber =
                    theme.relativeLineNumbers
                        ? (lineNumber == cursorLine
                            ? lineNumber
                            : (lineNumber - cursorLine).abs())
                        : lineNumber;

                return Container(
                  height: viewport.lineHeight,
                  width: gutterWidth,
                  color:
                      isCursorLine
                          ? theme.lineHighlightColor
                          : Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MouseRegion(
                            onEnter: (_) {
                              setState(() {
                                hoveredLine = lineNumber;
                              });
                            },
                            onExit: (_) {
                              setState(() {
                                hoveredLine = null;
                              });
                            },
                            child: GestureDetector(
                              onTap: () {
                                if (widget.buffer.breakpointManager
                                    .hasBreakpoint(lineNumber - 1)) {
                                  widget.buffer.breakpointManager
                                      .removeBreakpoint(lineNumber - 1);
                                } else {
                                  widget.buffer.breakpointManager.addBreakpoint(
                                    lineNumber - 1,
                                  );
                                }
                              },
                              child:
                                  (widget.buffer.breakpointManager
                                              .hasBreakpoint(lineNumber - 1) ||
                                          hoveredLine == lineNumber)
                                      ? Builder(
                                        builder: (context) {
                                          final isBreakpointLine = widget
                                              .buffer
                                              .breakpointManager
                                              .hasBreakpoint(lineNumber - 1);
                                          return Container(
                                            height: viewport.lineHeight - 8,
                                            width: viewport.lineHeight - 8,
                                            decoration: BoxDecoration(
                                              color:
                                                  (hoveredLine == lineNumber &&
                                                          !isBreakpointLine)
                                                      ? Colors.red.withOpacity(
                                                        0.5,
                                                      )
                                                      : Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    viewport.lineHeight / 2,
                                                  ),
                                            ),
                                          );
                                        },
                                      )
                                      : Text(
                                        displayNumber.toString(),
                                        style: theme.baseStyle.copyWith(
                                          fontSize: viewport.getFontSize(),
                                          height: viewport.textHeightFactor,
                                          color:
                                              isCursorLine
                                                  ? Colors.white
                                                  : Colors.grey,
                                        ),
                                      ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: widget.buffer.theme.gutterRightSize,
                        child: widget.buffer.gutter.get(lineNumber - 1),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateGutterWidth() {
    return widget.buffer.viewport.getGutterWidth();
  }
}
