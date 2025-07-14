import 'dart:io';

import 'package:codiaq_editor/src/input/custom_text_edit.dart';
import 'package:codiaq_editor/src/input/keyboard_listener.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../buffer/buffer.dart';
import '../buffer/event.dart';
import '../buffer/popup.dart';
import '../window/cursor.dart';
import '../window/selection.dart';
import 'buffer_painter.dart';
import 'gutter_widget.dart';

class BufferRenderer extends StatefulWidget {
  final Buffer buffer;
  final bool expand;
  final bool renderFullHeight;
  const BufferRenderer({
    super.key,
    required this.buffer,
    this.expand = true,
    this.renderFullHeight = false,
  });

  @override
  State<BufferRenderer> createState() => _BufferRendererState();
}

class _BufferRendererState extends State<BufferRenderer>
    with TickerProviderStateMixin {
  int? _selectionAnchorLine;
  int? _selectionAnchorColumn;
  bool _isDraggingSelection = false;
  DateTime? _lastTapDownTime;
  late AnimationController _scrollController;
  double _lastScrollVelocityY = 0.0;
  double _lastScrollVelocityX = 0.0;

  @override
  void initState() {
    super.initState();
    widget.buffer.events.addListener((event) {
      if (mounted) {
        setState(() {});
      }
    });
    _scrollController = AnimationController.unbounded(vsync: this)
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll(double deltaY, double deltaX) {
    if (deltaY.abs() > deltaX.abs()) {
      deltaX = 0;
    } else {
      deltaY = 0;
    }

    var scrollOffsetY = widget.buffer.viewport.scrollOffsetY;
    var scrollOffsetX = widget.buffer.viewport.scrollOffsetX;
    final double lineHeight = widget.buffer.viewport.lineHeight;
    int newTopLine = widget.buffer.viewport.topLine;

    double newYOffset = scrollOffsetY + deltaY;
    double newXOffset = scrollOffsetX + deltaX;

    while (newYOffset >= lineHeight) {
      newYOffset -= lineHeight;
      newTopLine += 1;
    }
    while (newYOffset < 0 && newTopLine > 0) {
      newTopLine -= 1;
      newYOffset += lineHeight;
    }
    newYOffset = newYOffset.clamp(0.0, double.infinity);
    newXOffset = newXOffset.clamp(0.0, double.infinity);

    if (!widget.renderFullHeight) {
      widget.buffer.viewport.setTopLine(newTopLine);
      widget.buffer.viewport.setScrollOffsetY(newYOffset);
      widget.buffer.viewport.setScrollOffsetX(newXOffset);
    }

    const double velocityFactor = 0.05;
    _lastScrollVelocityY = deltaY * velocityFactor;
    _lastScrollVelocityX = deltaX * velocityFactor;
  }

  void _startFlingAnimation() {
    if (_lastScrollVelocityY.abs() < 0.1 && _lastScrollVelocityX.abs() < 0.1) {
      return;
    }

    final physics =
        Platform.isIOS ? BouncingScrollPhysics() : ClampingScrollPhysics();

    // Calculate current vertical scroll position in pixels
    final double currentYPosition =
        widget.buffer.viewport.topLine * widget.buffer.viewport.lineHeight +
        widget.buffer.viewport.scrollOffsetY;
    final double maxYExtent =
        widget.buffer.viewport.lineHeight * widget.buffer.lines.length;
    final metricsY = FixedScrollMetrics(
      minScrollExtent: 0.0,
      maxScrollExtent: maxYExtent,
      pixels: currentYPosition,
      viewportDimension: widget.buffer.viewport.pixelHeight,
      axisDirection: AxisDirection.down,
      devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
    );

    // Calculate current horizontal scroll position
    final double maxXExtent =
        widget.buffer.lines.maxLineLength * widget.buffer.viewport.charWidth;
    final metricsX = FixedScrollMetrics(
      minScrollExtent: 0.0,
      maxScrollExtent: maxXExtent,
      pixels: widget.buffer.viewport.scrollOffsetX,
      viewportDimension: widget.buffer.viewport.pixelWidth,
      axisDirection: AxisDirection.right,
      devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
    );

    final simulationY = physics.createBallisticSimulation(
      metricsY,
      _lastScrollVelocityY,
    );
    final simulationX = physics.createBallisticSimulation(
      metricsX,
      _lastScrollVelocityX,
    );

    if (simulationY == null && simulationX == null) {
      return;
    }

    _scrollController.stop();
    _scrollController.animateWith(simulationY ?? simulationX!).then((_) {
      _lastScrollVelocityY = 0.0;
      _lastScrollVelocityX = 0.0;
    });

    _scrollController.addListener(() {
      double newYOffset = widget.buffer.viewport.scrollOffsetY;
      double newXOffset = widget.buffer.viewport.scrollOffsetX;
      int newTopLine = widget.buffer.viewport.topLine;

      if (simulationY != null) {
        final newYPosition = simulationY.x(_scrollController.value);
        newTopLine = (newYPosition / widget.buffer.viewport.lineHeight).floor();
        newYOffset = newYPosition % widget.buffer.viewport.lineHeight;
        newYOffset = newYOffset.clamp(0.0, double.infinity);
      }

      if (simulationX != null) {
        newXOffset = simulationX.x(_scrollController.value);
        newXOffset = newXOffset.clamp(0.0, double.infinity);
      }

      if (!widget.renderFullHeight) {
        widget.buffer.viewport.setTopLine(newTopLine);
        widget.buffer.viewport.setScrollOffsetY(newYOffset);
        widget.buffer.viewport.setScrollOffsetX(newXOffset);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = widget.buffer.theme;

    return LayoutBuilder(
      builder: (context, constraints) {
        widget.buffer.viewport.pixelWidth = constraints.maxWidth;
        widget.buffer.viewport.pixelHeight = constraints.maxHeight;
        widget.buffer.viewport.computeSizes();
        var theoreticalHeight =
            widget.buffer.viewport.lineHeight * widget.buffer.lines.length;
        var maxHeight = constraints.maxHeight;
        var maxWidth = constraints.maxWidth;
        if (widget.expand) {
          maxWidth = double.infinity;
        } else {
          maxWidth = (widget.buffer.lines.maxLineLength *
                  widget.buffer.viewport.charWidth)
              .clamp(0.0, constraints.maxWidth);
          maxHeight =
              (theoreticalHeight < constraints.maxHeight)
                  ? theoreticalHeight
                  : constraints.maxHeight;
        }
        if (widget.renderFullHeight) {
          maxHeight = theoreticalHeight;
        }
        return Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(),
          height: maxHeight,
          width: maxWidth,
          child: Row(
            children: [
              if (theme.showGutter) GutterWidget(buffer: widget.buffer),
              Expanded(
                child: Stack(
                  children: [
                    wrapWithListener(
                      Listener(
                        onPointerSignal: (PointerSignalEvent event) {
                          if (event is PointerScrollEvent) {
                            _handleScroll(
                              event.scrollDelta.dy,
                              event.scrollDelta.dx,
                            );
                          }
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.text,
                          onHover: _handleHover,
                          child: GestureDetector(
                            onPanUpdate: _handlePanUpdate,
                            onPanEnd: (details) {
                              _isDraggingSelection = false;
                              _selectionAnchorLine = null;
                              _selectionAnchorColumn = null;
                              _startFlingAnimation();
                            },
                            onTapDown: _handleTapDown,
                            onTapUp: _handleTapUp,
                            child: CustomPaint(
                              painter: BufferPainter(widget.buffer),
                              size: Size.infinite,
                            ),
                          ),
                        ),
                      ),
                    ),
                    _drawDragHandle(true),
                    _drawDragHandle(false),
                    ...getPopups(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _drawDragHandle(bool start) {
    if (!widget.buffer.selection.isActive) return SizedBox.shrink();

    if (Platform.isIOS || Platform.isAndroid) {
      final lineHeight = widget.buffer.viewport.lineHeight;

      final selectionStart = widget.buffer.selection.start!;
      final selectionEnd = widget.buffer.selection.end!;
      final isForward =
          selectionStart.line < selectionEnd.line ||
          (selectionStart.line == selectionEnd.line &&
              selectionStart.column <= selectionEnd.column);
      final visualStart = isForward ? selectionStart : selectionEnd;
      final visualEnd = isForward ? selectionEnd : selectionStart;

      // Always use visualStart/End for rendering
      final handlePos =
          start
              ? widget.buffer.viewport.positionFromCursorPos(
                CursorPosition(visualStart.line, visualStart.column),
              )
              : widget.buffer.viewport.positionFromCursorPos(
                CursorPosition(visualEnd.line, visualEnd.column),
              );

      Offset adjustedPos;
      if (visualStart.line < visualEnd.line) {
        adjustedPos = handlePos.translate(
          -(lineHeight / 2),
          start ? -lineHeight / 2 : lineHeight * 0.8,
        );
      } else {
        adjustedPos = handlePos.translate(
          -(lineHeight / 2),
          start ? lineHeight * 0.8 : -lineHeight / 2,
        );
      }

      return Positioned(
        left: adjustedPos.dx - (widget.buffer.viewport.scrollOffsetX * 2),
        top: adjustedPos.dy - (widget.buffer.viewport.scrollOffsetY * 2),
        child: GestureDetector(
          onPanUpdate: _handlePanUpdate,
          onTapDown: (info) {
            setState(() {
              final anchor = start ? visualStart : visualEnd;
              _selectionAnchorLine = anchor.line;
              _selectionAnchorColumn = anchor.column;
              _isDraggingSelection = true;
            });
          },
          onTapUp: _handleTapUp,
          child: Container(
            width: lineHeight * 0.8,
            height: lineHeight * 0.8,
            decoration: BoxDecoration(
              color: widget.buffer.theme.selectionColor,
              borderRadius: BorderRadius.circular(lineHeight),
            ),
          ),
        ),
      );
    }

    return SizedBox.shrink();
  }

  void _handleHover(PointerHoverEvent details) {
    var offset = details.localPosition;
    var cursorPos = widget.buffer.viewport.posFromOffset(offset);
    widget.buffer.events.emit(BufferEventType.hover.index, {
      'line': cursorPos.line,
      'col': cursorPos.column,
      'offset': offset,
    });

    checkPopupsOutsideOfViewport(details.position);
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_isDraggingSelection) {
      final localPos = details.localPosition;
      final tapInfo = widget.buffer.viewport.posFromOffset(localPos);
      final line = tapInfo.line;
      final col = tapInfo.column;

      if (_selectionAnchorLine != null && _selectionAnchorColumn != null) {
        // Update selection range in the window or buffer
        print(
          "Dragging selection from $_selectionAnchorLine:$_selectionAnchorColumn to $line:$col",
        );
        Selection newSelection = Selection();
        newSelection.start = CursorPosition(
          _selectionAnchorLine!,
          _selectionAnchorColumn!,
        );
        newSelection.end = CursorPosition(line, col);
        widget.buffer.setCursorPosition(line, col);
        widget.buffer.setSelection(newSelection);
      }
    } else {
      // If not dragging selection, fall back to scroll behavior (optional)
      //_triggerScrollbarFade();

      _handleScroll(-details.delta.dy, -details.delta.dx);
    }
  }

  void _handleTapDown(TapDownDetails details) {
    var offset = details.localPosition;
    var cursorPos = widget.buffer.viewport.posFromOffset(offset);

    if (_lastTapDownTime != null &&
        DateTime.now().difference(_lastTapDownTime!) <
            Duration(milliseconds: 300)) {
      // Double tap detected, clear selection
      widget.buffer.selection.clear();
      _lastTapDownTime = null;
      var range = widget.buffer.lines.wordAtPos(cursorPos);
      widget.buffer.setSelection(
        Selection(
          start: CursorPosition(range.start.line, range.start.column),
          end: CursorPosition(range.end.line, range.end.column),
        ),
      );
      print("Double tap detected, clearing selection");
      return;
    }

    _lastTapDownTime = DateTime.now();
    bool isInText = widget.buffer.viewport.posIsInText(cursorPos);
    if (widget.buffer.selection.isActive) {
      // If the tap is outside of text and a selection is active, clear the selection
      widget.buffer.selection.clear();
    }
    print("Tap at: ${cursorPos.line}, ${cursorPos.column}");
    widget.buffer.setCursorPosition(cursorPos.line, cursorPos.column);
    _selectionAnchorLine = cursorPos.line;
    _selectionAnchorColumn = cursorPos.column;
    _isDraggingSelection = true;
    checkPopupsOutsideOfViewport(details.globalPosition, tap: true);
    if (!widget.buffer.focusNode.hasFocus) {
      widget.buffer.focusNode.requestFocus();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    // Reset selection anchor when tap is released
    _selectionAnchorLine = null;
    _selectionAnchorColumn = null;
    _isDraggingSelection = false;
  }

  List<Widget> getPopups() {
    var size = Size(
      widget.buffer.viewport.pixelWidth,
      widget.buffer.viewport.pixelHeight,
    );
    if (size.width <= 0 || size.height <= 0) {
      return [];
    }
    List<Popup> popups = widget.buffer.popupManager.popups.toList();
    popups.sort((a, b) => a.zIndex.compareTo(b.zIndex));
    return popups.map((popup) {
      var position =
          (popup.arbitraryPosition == null)
              ? widget.buffer.viewport.positionFromCursorPos(popup.position)
              : Offset(popup.arbitraryPosition!.x, popup.arbitraryPosition!.y);
      var pixelWidth = widget.buffer.viewport.pixelWidth;
      var left =
          position.dx +
          popup.direction.getOffset().dx -
          widget.buffer.viewport.scrollOffsetX * 2;
      var top =
          position.dy +
          popup.direction.getOffset().dy -
          widget.buffer.viewport.scrollOffsetY * 2;
      var gutterWidth = widget.buffer.viewport.getGutterWidth() + 10;
      var maxWidth = pixelWidth - left - gutterWidth; // 20px padding:w
      if (maxWidth > 750) {
        maxWidth = 750; // Limit max width to 500px
      }
      var maxHeight = size.height - top - gutterWidth; // 20px padding
      if (maxHeight < 0 || maxHeight < 50) {
        maxHeight = 50; // Ensure minimum height
      } else {
        maxHeight = maxHeight.clamp(50.0, double.infinity); // Clamp to min 50px
      }
      print("pixel width: $pixelWidth, left: $left, maxWidth: $maxWidth");
      return Positioned(
        left: left,
        top: top,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            minWidth: 50,
            maxHeight: maxHeight,
            minHeight: 50,
          ),
          decoration: BoxDecoration(
            color:
                widget.buffer.theme.popupBackgroundColor ??
                widget.buffer.theme.backgroundColor,
            border: Border.all(
              color: widget.buffer.theme.dividerColor,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: popup.content,
        ),
      );
    }).toList();
  }

  Widget wrapWithListener(Widget child) {
    if (Platform.isIOS || Platform.isAndroid) {
      return CustomTextEdit(
        deleteDetection: true,
        onDelete: () {
          print("Delete pressed");
          widget.buffer.inputHandler.onKeyEvent(
            widget.buffer.focusNode,
            KeyDownEvent(
              timeStamp: Duration.zero,
              physicalKey: PhysicalKeyboardKey.backspace,
              logicalKey: LogicalKeyboardKey.backspace,
            ),
          );
        },
        onComposing: (s) {
          print("Composing: $s");
        },
        onAction: (inputAction) {
          print("Action: $inputAction");
        },
        onKeyEvent: (FocusNode node, KeyEvent event) {
          if (forwardKeyEventToPopups(event)) {
            return KeyEventResult.handled;
          }
          return widget.buffer.inputHandler.onKeyEvent(node, event);
        },
        onInsert: (text) {
          print("INSERT: $text");
          widget.buffer.inputHandler.onInsert(text);
        },
        focusNode: widget.buffer.focusNode,
        child: child,
      );
    } else {
      return CustomKeyboardListener(
        focusNode: widget.buffer.focusNode,
        onInsert: widget.buffer.inputHandler.onInsert,

        onComposing: (s) {
          print("Composing: $s");
        },
        onKeyEvent: widget.buffer.inputHandler.onKeyEvent,
        child: child,
      );
    }
    return child;
  }

  void hoverOutsideOfPopup(
    Popup popup,
    Offset globalPos,
    double threshold, {
    bool tap = false,
  }) {
    // Check if the global position is outside, but add a small margin of 50 px
    if (tap && popup.closeOnTapOutside == false) {
      return;
    }
    if (!tap && popup.closeOnExit == false) {
      return;
    }
    final renderBox =
        popup.key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final localPos = renderBox.globalToLocal(globalPos);
      final size = renderBox.size;
      if (localPos.dx < -threshold ||
          localPos.dx > size.width + threshold ||
          localPos.dy < -threshold ||
          localPos.dy > size.height + threshold) {
        print(
          "closing because of ${(tap ? "tap" : "hover")} outside of popup: ${popup.type}",
        );
        widget.buffer.popupManager.removePopup(popup);
      }
    }
  }

  void checkPopupsOutsideOfViewport(Offset globalPos, {bool tap = false}) {
    // Check if any popups are outside the viewport and remove them
    final popups = widget.buffer.popupManager.popups;
    for (var popup in popups) {
      hoverOutsideOfPopup(popup, globalPos, tap ? 0 : 30, tap: tap);
    }
  }

  bool forwardKeyEventToPopups(KeyEvent event) {
    // Forward key events to popups
    final popups = widget.buffer.popupManager.popups;
    for (var popup in popups) {
      print(
        "Forwarding key event($event) to popup: ${popup.type}, controller: ${popup.controller}",
      );
      if (popup.controller?.onKeyEvent(event) ?? false) return true;
    }
    print("No popup handled the key event: $event");
    return false;
  }

  //void _handleScroll(double deltaY, double deltaX) {
  //  if (deltaY.abs() > deltaX.abs()) {
  //    deltaX = 0;
  //  } else {
  //    deltaY = 0;
  //  }
  //  var scrollOffsetY = widget.buffer.viewport.scrollOffsetY;
  //  var scrollOffsetX = widget.buffer.viewport.scrollOffsetX;
  //  final double lineHeight = widget.buffer.viewport.lineHeight;
  //
  //  double newYOffset = scrollOffsetY + deltaY;
  //  int newTopLine = widget.buffer.viewport.topLine;
  //  double newXOffset = scrollOffsetX + deltaX;
  //
  //  // Vertical scroll
  //  while (newYOffset >= lineHeight) {
  //    newYOffset -= lineHeight;
  //    newTopLine += 1;
  //  }
  //  while (newYOffset < 0 && newTopLine > 0) {
  //    newTopLine -= 1;
  //    newYOffset += lineHeight;
  //  }
  //  newYOffset = newYOffset.clamp(0.0, double.infinity);
  //
  //  // Horizontal scroll
  //  newXOffset = newXOffset.clamp(0.0, double.infinity);
  //
  //  if (newTopLine != widget.buffer.viewport.topLine &&
  //      !widget.renderFullHeight) {
  //    widget.buffer.viewport.setTopLine(newTopLine);
  //  }
  //  if (!widget.renderFullHeight)
  //    widget.buffer.viewport.setScrollOffsetY(newYOffset);
  //  widget.buffer.viewport.setScrollOffsetX(newXOffset);
  //}
}
