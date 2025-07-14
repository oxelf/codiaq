//import 'package:codiaq_editor/codiaq_editor.dart';
//import 'package:codiaq_editor/src/input/custom_text_edit.dart';
//import 'package:codiaq_editor/src/ui/gutter_widget.dart';
//import 'dart:async';
//import 'package:flutter/gestures.dart';
//import 'package:flutter/material.dart';
//import '../buffer/popup.dart';
//import 'window_painter.dart';
//import "../window/viewport.dart" as vp;
//
//class WindowWidget extends StatefulWidget {
//  final Window window;
//
//  const WindowWidget({super.key, required this.window});
//
//  @override
//  State<WindowWidget> createState() => _WindowWidgetState();
//}
//
//class _WindowWidgetState extends State<WindowWidget> {
//  bool _showScrollbars = false;
//  Timer? _hideScrollbarTimer;
//  bool _isDraggingVertical = false;
//  bool _isDraggingHorizontal = false;
//  late WindowPainter painter;
//  EditorTheme? _lastTheme;
//  double? _lastViewportHeight;
//  int? _selectionAnchorLine;
//  int? _selectionAnchorColumn;
//  bool _isDraggingSelection = false;
//  Diagnostic? lastDiagnostic;
//  bool initialized = false;
//
//  void _updateViewportIfNeeded(double visibleHeight) {
//    final newHeight = (visibleHeight / painter.lineHeight).round() + 1;
//    if (_lastViewportHeight != newHeight) {
//      _lastViewportHeight = newHeight.toDouble();
//      widget.window.changeViewport(
//        vp.Viewport(topLine: widget.window.viewport.topLine, height: newHeight),
//      );
//    }
//  }
//
//  @override
//  void didChangeDependencies() {
//    super.didChangeDependencies();
//    print("WindowWidget didChangeDependencies called");
//    final theme = EditorThemeProvider.of(context);
//    if (_lastTheme != theme) {
//      painter = WindowPainter(widget.window, theme);
//      _lastTheme = theme;
//    }
//  }
//
//  @override
//  void initState() {
//    super.initState();
//    widget.window.addListener(_onWindowUpdate);
//  }
//
//  @override
//  void dispose() {
//    widget.window.removeListener(_onWindowUpdate);
//    _hideScrollbarTimer?.cancel();
//    super.dispose();
//  }
//
//  void _onWindowUpdate() {
//    if (mounted) setState(() {});
//  }
//
//  void _triggerScrollbarFade({bool force = false}) {
//    setState(() => _showScrollbars = true);
//    _hideScrollbarTimer?.cancel();
//    _hideScrollbarTimer = Timer(
//      Duration(milliseconds: force ? 2500 : 2000),
//      () {
//        if (!_isDraggingVertical && !_isDraggingHorizontal && mounted) {
//          setState(() => _showScrollbars = false);
//        }
//      },
//    );
//  }
//
//  void _handleScroll(double deltaY, double deltaX) {
//    final vp.Viewport viewport = widget.window.viewport;
//    final double lineHeight = painter.lineHeight;
//    final double charWidth = painter.charWidth;
//
//    double newYOffset = viewport.scrollOffsetY + deltaY;
//    int newTopLine = viewport.topLine;
//    double newXOffset = viewport.scrollOffsetX + deltaX;
//
//    // Vertical scroll
//    while (newYOffset >= lineHeight) {
//      newYOffset -= lineHeight;
//      newTopLine += 1;
//    }
//    while (newYOffset < 0 && newTopLine > 0) {
//      newTopLine -= 1;
//      newYOffset += lineHeight;
//    }
//    newYOffset = newYOffset.clamp(0.0, double.infinity);
//
//    // Horizontal scroll
//    newXOffset = newXOffset.clamp(0.0, double.infinity);
//
//    if (newTopLine != viewport.topLine) {
//      widget.window.changeViewportTopLine(newTopLine);
//    }
//    widget.window.changeViewportScrollY(newYOffset);
//    widget.window.changeViewportScrollX(newXOffset);
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    print("WindowWidget build called");
//    var theme = EditorThemeProvider.of(context);
//    final vp.Viewport viewport = widget.window.viewport;
//
//    return Container(
//      clipBehavior: Clip.hardEdge,
//      decoration: BoxDecoration(),
//      child: LayoutBuilder(
//        builder: (context, constraints) {
//          final visibleWidth = constraints.maxWidth;
//          final visibleHeight = constraints.maxHeight;
//
//          _updateViewportIfNeeded(visibleHeight);
//
//          final contentWidth = painter.getWidthForLine(
//            " " * widget.window.buffer.maxLineLength,
//          );
//          final contentHeight =
//              painter.lineHeight * widget.window.buffer.lines.length;
//
//          final verticalThumbHeight =
//              (visibleHeight / contentHeight).clamp(0.05, 1.0) * visibleHeight;
//          final verticalThumbTop =
//              (viewport.topLine * painter.lineHeight + viewport.scrollOffsetY) /
//              contentHeight *
//              visibleHeight;
//
//          final horizontalThumbWidth =
//              (visibleWidth / contentWidth).clamp(0.05, 1.0) * visibleWidth;
//          final horizontalThumbLeft =
//              (viewport.scrollOffsetX / contentWidth) * visibleWidth;
//
//          return Row(
//            children: [
//              GutterWidget(
//                window: widget.window,
//                painter: painter,
//                theme: theme,
//              ),
//              Container(
//                child: Expanded(
//                  child: Stack(
//                    children: [
//                      // Gesture + CustomPaint
//                      CustomTextEdit(
//                        onDelete: () {
//                          print("Delete pressed");
//                        },
//                        onComposing: (s) {
//                          print("Composing: $s");
//                        },
//                        onAction: (inputAction) {
//                          print("Action: $inputAction");
//                        },
//                        onKeyEvent: widget.window.inputHandler.onKeyEvent,
//                        onInsert: (text) {
//                          print("Insert: $text");
//                        },
//                        focusNode: widget.window.focusNode,
//                        child: Listener(
//                          onPointerSignal: (event) {
//                            if (event is PointerScrollEvent) {
//                              _triggerScrollbarFade();
//                              _handleScroll(
//                                event.scrollDelta.dy,
//                                event.scrollDelta.dx,
//                              );
//                            }
//                          },
//                          child: MouseRegion(
//                            cursor: SystemMouseCursors.text,
//
//                            onHover: (details) {
//                              if (!widget.window.isMobile) {
//                                final localPos = details.localPosition;
//                                _handleHover(localPos);
//                              }
//                              checkPopupsOutsideOfViewport(details.position);
//                            },
//                            child: GestureDetector(
//                              onLongPressDown: (details) {
//                                if (!widget.window.isMobile) {
//                                  return;
//                                }
//                                final localPos = details.localPosition;
//                                _handleHover(localPos);
//                              },
//                              //onDoubleTapDown: (details) {
//                              //  if (!widget.window.isMobile) {
//                              //    return;
//                              //  }
//                              //  final localPos = details.localPosition;
//                              //  _handleHover(localPos);
//                              //},
//                              onPanEnd: (details) {
//                                _isDraggingSelection = false;
//                                _selectionAnchorLine = null;
//                                _selectionAnchorColumn = null;
//                              },
//                              onPanUpdate: (details) {
//                                if (_isDraggingSelection) {
//                                  final localPos = details.localPosition;
//                                  final tapInfo = painter.computeTapPosition(
//                                    localPos,
//                                  );
//                                  final line = tapInfo.$1;
//                                  final col = tapInfo.$2;
//
//                                  if (_selectionAnchorLine != null &&
//                                      _selectionAnchorColumn != null) {
//                                    // Update selection range in the window or buffer
//                                    Selection newSelection = Selection();
//                                    newSelection.start = CursorPosition(
//                                      _selectionAnchorLine!,
//                                      _selectionAnchorColumn!,
//                                    );
//                                    newSelection.end = CursorPosition(
//                                      line,
//                                      col,
//                                    );
//                                    widget.window.setCursorPosition(line, col);
//                                    widget.window.setSelection(newSelection);
//                                  }
//                                  widget.window.focusNode.requestFocus();
//                                } else {
//                                  // If not dragging selection, fall back to scroll behavior (optional)
//                                  _triggerScrollbarFade();
//                                  _handleScroll(
//                                    -details.delta.dy,
//                                    -details.delta.dx,
//                                  );
//                                }
//                              },
//                              onTapDown: (details) {
//                                final tapInfo = painter.tryComputeTapPosition(
//                                  details.localPosition,
//                                );
//                                if (tapInfo == null) {
//                                  // Not tapping on text, ignore
//                                  if (widget.window.selection.isActive) {
//                                    widget.window.selection.clear();
//                                  } else {
//                                    final newTapInfo = painter
//                                        .computeTapPosition(
//                                          details.localPosition,
//                                        );
//                                    var line = newTapInfo.$1;
//                                    var col = newTapInfo.$2;
//                                    print(
//                                      "Tapped outside text, setting cursor to $line:$col",
//                                    );
//                                    widget.window.setCursorPosition(line, col);
//                                  }
//                                  return;
//                                }
//
//                                final line = tapInfo.$1;
//                                final col = tapInfo.$2;
//                                var selection = widget.window.selection;
//                                if (selection.isActive) {
//                                  if ((selection.start!.line == line &&
//                                          selection.start!.column == col) &&
//                                      widget.window.isMobile) {
//                                    _selectionAnchorLine = selection.end!.line;
//                                    _selectionAnchorColumn =
//                                        selection.end!.column;
//                                    _isDraggingSelection = true;
//                                    // we are on mobile, and we tapped on the
//                                    // drag handles, so we do not clear the selection,
//                                    // but start dragging the selection
//                                    return;
//                                  }
//                                  if ((selection.end!.line == line &&
//                                          selection.end!.column == col) &&
//                                      widget.window.isMobile) {
//                                    _selectionAnchorLine =
//                                        selection.start!.line;
//                                    _selectionAnchorColumn =
//                                        selection.start!.column;
//                                    _isDraggingSelection = true;
//                                    return;
//                                  }
//                                }
//                                if (col <
//                                    widget.window.buffer.lines[line].length) {
//                                  widget.window.setCursorPosition(line, col);
//                                } else {
//                                  // If tapped outside the line length, move to end of line
//                                  widget.window.setCursorPosition(
//                                    line,
//                                    widget.window.buffer.lines[line].length,
//                                  );
//                                }
//
//                                // Start drag selection anchor
//                                _selectionAnchorLine = line;
//                                _selectionAnchorColumn = col;
//                                _isDraggingSelection = true;
//
//                                if (!widget.window.focusNode.hasFocus)
//                                  widget.window.focusNode.requestFocus();
//                              },
//                              onTapUp: (details) {
//                                if (_isDraggingSelection) {
//                                  // If we were dragging selection, finalize it
//                                  final tapInfo = painter.computeTapPosition(
//                                    details.localPosition,
//                                  );
//                                  final line = tapInfo.$1;
//                                  final col = tapInfo.$2;
//
//                                  Selection newSelection = Selection();
//                                  newSelection.start = CursorPosition(
//                                    _selectionAnchorLine!,
//                                    _selectionAnchorColumn!,
//                                  );
//                                  newSelection.end = CursorPosition(line, col);
//                                  widget.window.setSelection(newSelection);
//                                  _isDraggingSelection = false;
//                                  _selectionAnchorLine = null;
//                                  _selectionAnchorColumn = null;
//                                }
//                                _triggerScrollbarFade();
//                              },
//
//                              child: CustomPaint(
//                                painter: painter,
//                                size: Size.infinite,
//                              ),
//                            ),
//                          ),
//                        ),
//                      ),
//
//                      // Vertical Scrollbar
//                      if (_showScrollbars && contentHeight > visibleHeight)
//                        Positioned(
//                          top: verticalThumbTop,
//                          right: 2,
//                          width: 6,
//                          height: verticalThumbHeight,
//                          child: GestureDetector(
//                            onVerticalDragStart: (_) {
//                              _isDraggingVertical = true;
//                              _hideScrollbarTimer?.cancel();
//                            },
//                            onVerticalDragUpdate: (details) {
//                              final scrollableHeight =
//                                  contentHeight - visibleHeight;
//                              final trackHeight =
//                                  visibleHeight - verticalThumbHeight;
//                              final scrollRatio =
//                                  scrollableHeight / trackHeight;
//                              final deltaY = details.delta.dy * scrollRatio;
//                              _handleScroll(deltaY, 0);
//                            },
//                            onVerticalDragEnd: (_) {
//                              _isDraggingVertical = false;
//                              _triggerScrollbarFade(force: true);
//                            },
//                            child: _scrollbarThumb(),
//                          ),
//                        ),
//
//                      // Horizontal Scrollbar
//                      if (_showScrollbars && contentWidth > visibleWidth)
//                        Positioned(
//                          bottom: 2,
//                          left: horizontalThumbLeft,
//                          height: 6,
//                          width: horizontalThumbWidth,
//                          child: GestureDetector(
//                            onHorizontalDragStart: (_) {
//                              _isDraggingHorizontal = true;
//                              _hideScrollbarTimer?.cancel();
//                            },
//                            onHorizontalDragUpdate: (details) {
//                              final scrollableWidth =
//                                  contentWidth - visibleWidth;
//                              final trackWidth =
//                                  visibleWidth - horizontalThumbWidth;
//                              final scrollRatio = scrollableWidth / trackWidth;
//                              final deltaX = details.delta.dx * scrollRatio;
//                              _handleScroll(0, deltaX);
//                            },
//                            onHorizontalDragEnd: (_) {
//                              _isDraggingHorizontal = false;
//                              _triggerScrollbarFade(force: true);
//                            },
//                            child: _scrollbarThumb(),
//                          ),
//                        ),
//                      //...getPopups(),
//                    ],
//                  ),
//                ),
//              ),
//            ],
//          );
//        },
//      ),
//    );
//  }
//
//  List<Widget> getPopups() {
//    List<Popup> popups = widget.window.buffer.popupManager.popups.toList();
//    print("Popups count: ${popups.length}");
//    popups.sort((a, b) => a.zIndex.compareTo(b.zIndex));
//    return popups.map((popup) {
//      var position =
//          (popup.arbitraryPosition == null)
//              ? painter.positionFromCursorPos(popup.position)
//              : (popup.arbitraryPosition!.x, popup.arbitraryPosition!.y);
//      return Positioned(
//        left: position.$1 + popup.direction.getOffset().dx,
//        top: position.$2 + popup.direction.getOffset().dy,
//        child: Container(key: popup.key, child: popup.content),
//      );
//    }).toList();
//  }
//
//  void _handleHover(Offset localPosition) {
//    final tapInfo = painter.tryComputeTapPosition(localPosition);
//    if (tapInfo == null) {
//      return; // Not hovering over text
//    }
//    final line = tapInfo.$1;
//    final col = tapInfo.$2;
//    //widget.window.buffer.diagnostics.diagnosticsForLine(line).forEach((
//    //  diagnostic,
//    //) {
//    //  if (diagnostic.startCol <= col && diagnostic.endCol >= col) {
//    //    print("Hovered over diagnostic: ${diagnostic.message}");
//    //    widget.window.buffer.popupManager.addPopup(
//    //      Popup(
//    //        zIndex: 1,
//    //        type: "hover",
//    //        content: Container(
//    //          width: 300,
//    //          height: 100,
//    //          padding: const EdgeInsets.all(8),
//    //          color: Colors.black87,
//    //          child: Text(
//    //            diagnostic.message,
//    //            style: TextStyle(color: Colors.white),
//    //          ),
//    //        ),
//    //        position: CursorPosition(line, col),
//    //      ),
//    //    );
//    //    //widget.window.buffer.diagnostics.showDiagnostic(diagnostic);
//    //  }
//    //});
//    widget.window.buffer.events.emit(BufferEventType.hover.index, {
//      'line': line,
//      'col': col,
//    });
//    print("Hovered at line $line, column $col");
//  }
//
//  void hoverOutsideOfPopup(Popup popup, Offset globalPos) {
//    // Check if the global position is outside, but add a small margin of 50 px
//    final renderBox =
//        popup.key.currentContext?.findRenderObject() as RenderBox?;
//    if (renderBox != null) {
//      final localPos = renderBox.globalToLocal(globalPos);
//      final size = renderBox.size;
//      if (localPos.dx < -30 ||
//          localPos.dx > size.width + 30 ||
//          localPos.dy < -30 ||
//          localPos.dy > size.height + 30) {
//        widget.window.buffer.popupManager.removePopup(popup);
//      }
//    }
//  }
//
//  void checkPopupsOutsideOfViewport(Offset globalPos) {
//    // Check if any popups are outside the viewport and remove them
//    final popups = widget.window.buffer.popupManager.popups;
//    for (var popup in popups) {
//      hoverOutsideOfPopup(popup, globalPos);
//    }
//  }
//
//  Widget _scrollbarThumb() {
//    return Container(
//      decoration: BoxDecoration(
//        color: Colors.grey.shade600.withOpacity(0.7),
//        borderRadius: BorderRadius.circular(3),
//      ),
//    );
//  }
//}
