//import 'dart:io';
//
//import 'package:codiaq_editor/src/buffer/diagnostic.dart';
//import 'package:codiaq_editor/src/input/input_handler.dart';
//import 'package:codiaq_editor/src/input/vim_adapter.dart';
//import 'package:codiaq_editor/src/plugin/window_plugin_manager.dart';
//import 'package:codiaq_editor/src/window/breakpoint.dart';
//import 'package:codiaq_editor/src/window/controller.dart';
//import 'package:flutter/cupertino.dart';
//
//import '../buffer/buffer.dart';
//import '../buffer/event.dart';
//import 'cursor.dart';
//import 'selection.dart';
//import 'viewport.dart' as vp;
//
//export 'cursor.dart';
//export 'selection.dart';
//export 'viewport.dart';
//
//class Window extends ChangeNotifier {
//  final Buffer buffer;
//  final vp.Viewport viewport;
//  final EditorController controller;
//  final CursorStyle cursorStyle;
//  late InputHandler inputHandler;
//  late VimAdapter vim;
//  FocusNode focusNode = FocusNode();
//  BreakpointManager breakpointManager = BreakpointManager();
//  late WindowPluginManager pluginManager = WindowPluginManager(this);
//  double lineHeight = 20;
//
//  Window({
//    required this.buffer,
//    required this.viewport,
//    FocusNode? overrideFocusNode,
//    this.cursorStyle = CursorStyle.block,
//  }) : controller = EditorController(buffer) {
//    inputHandler = InputHandler(this);
//    vim = VimAdapter(this);
//    if (overrideFocusNode != null) {
//      focusNode = overrideFocusNode;
//    }
//    buffer.events.addListener((event) {
//      if (event.type == "linesChanged") {
//        _adjustViewport();
//      }
//      notifyListeners();
//    });
//  }
//
//  /// Scroll viewport by N lines
//  void scroll(int delta) {
//    viewport.scroll(delta);
//    notifyListeners();
//  }
//
//  //void write(String text) {
//  //  buffer.insertLine(cursor.line, text);
//  //  notifyListeners();
//  //}
//
//  void changeViewportHeight(int newHeight) {
//    viewport.height = newHeight;
//    notifyListeners();
//  }
//
//  void changeViewportScrollY(double newScrollY) {
//    viewport.scrollOffsetY = newScrollY;
//    notifyListeners();
//  }
//
//  void changeViewportScrollX(double newScrollY) {
//    viewport.scrollOffsetX = newScrollY;
//    notifyListeners();
//  }
//
//  void changeViewportTopLine(int newTopLine) {
//    viewport.topLine = newTopLine;
//    notifyListeners();
//  }
//
//  void changeViewport(vp.Viewport newViewport) {
//    viewport.topLine = newViewport.topLine;
//    viewport.height = newViewport.height;
//    notifyListeners();
//  }
//
//  List<String> getVisibleLines() {
//    final allLines = buffer.getLines();
//    final start = viewport.topLine;
//    final end = (start + viewport.height).clamp(0, allLines.length);
//    return allLines.sublist(start, end);
//  }
//
//  void moveCursorDown() {
//    controller.moveCursorDown();
//    _adjustViewport();
//    notifyListeners();
//  }
//
//  void moveCursorUp() {
//    controller.moveCursorUp();
//    _adjustViewport();
//    notifyListeners();
//  }
//
//  void moveCursorLeft() {
//    controller.moveCursorLeft();
//    _adjustViewport();
//    notifyListeners();
//  }
//
//  void moveCursorRight() {
//    controller.moveCursorRight();
//    _adjustViewport();
//    notifyListeners();
//  }
//
//  void setCursorPosition(int line, int column) {
//    print("Setting cursor position to $line:$column");
//    controller.cursor.line = line;
//    controller.cursor.column = column;
//    //if (buffer.lines.get(line) == "") {
//    //  buffer.lines.insert(line, " ");
//    //}
//    _adjustViewport();
//    notifyListeners();
//  }
//
//  bool get isMobile => Platform.isIOS || Platform.isAndroid;
//
//  void _adjustViewport() {
//    print(
//      "Adjusting viewport for cursor at ${controller.cursor.line}:${controller.cursor.column}",
//    );
//    final cursorLine = controller.cursor.line;
//    if (cursorLine < viewport.topLine) {
//      viewport.topLine = cursorLine;
//    } else if (cursorLine >= viewport.topLine + viewport.height) {
//      viewport.topLine = cursorLine - viewport.height + 1;
//      // if we are at the end of the buffer, add a little scrollOffset to keep the cursor visible
//      if (viewport.topLine + viewport.height >= buffer.lines.length) {
//        viewport.scrollOffsetY = 10;
//      }
//    }
//  }
//
//  void setSelection(Selection selection) {
//    controller.selection.start = selection.start;
//    controller.selection.end = selection.end;
//    notifyListeners();
//  }
//
//  CursorPosition get cursor => controller.cursor;
//  Selection get selection => controller.selection;
//  DiagnosticManager get diagnostics => buffer.diagnostics;
//  EditorMode get mode => controller.mode;
//}
