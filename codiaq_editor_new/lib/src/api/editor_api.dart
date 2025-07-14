//import 'package:codiaq_editor/codiaq_editor.dart';
//
//import '../window/cursor.dart';
//import '../window/selection.dart';
//
//class BufferApi {
//  final Buffer buffer;
//
//  BufferApi(this.buffer);
//
//  void dispatchEvent(int event, [Map<String, dynamic>? data]) {
//    buffer.events.emit(event, data);
//  }
//
//  String get fileType => buffer.filetype;
//  String get filePath => buffer.path;
//
//  // cursor
//
//  void setCursor(int line, int column) {
//    buffer.setCursorPosition(line, column);
//  }
//
//  CursorPosition get cursor => buffer.cursor;
//
//  // selection
//
//  void setSelection(int startLine, int startCol, int endLine, int endCol) {
//    Selection selection = Selection();
//    selection.start = CursorPosition(startLine, startCol);
//    selection.end = CursorPosition(endLine, endCol);
//    buffer.setSelection(selection);
//  }
//
//  // viewport
//
//  int get viewportHeight => buffer.viewport.height;
//  int get viewportTopLine => buffer.viewport.topLine;
//  double get viewportOffsetX => buffer.viewport.scrollOffsetX;
//  double get viewportOffsetY => buffer.viewport.scrollOffsetY;
//  set viewportTopLine(int newTopLine) => buffer.viewport.setTopLine(newTopLine);
//  set viewportHeight(int newHeight) => buffer.viewport.setHeight(newHeight);
//  set viewportOffsetX(double newOffset) =>
//      buffer.viewport.setScrollOffsetX(newOffset);
//  set viewportOffsetY(double newOffset) =>
//      buffer.viewport.setScrollOffsetY(newOffset);
//
//  // text
//
//  List<String> getVisibleLines(int topLine, int height) => window.buffer
//      .getLinesInViewport(Viewport(topLine: topLine, height: height));
//  List<String> get lines => window.buffer.getLines();
//  set lines(List<String> newLines) => window.buffer.lines.setLines(newLines);
//
//  // diagnostics
//  List<Diagnostic> diagnosticsForLine(int line) =>
//      window.buffer.diagnostics.diagnosticsForLine(line);
//  void addDiagnostic(Diagnostic diagnostic) =>
//      window.buffer.diagnostics.addDiagnostic(diagnostic);
//
//  // highlights
//  List<Highlight> highlightsForLine(int line) =>
//      window.buffer.highlights.getHighlightsForLine(line);
//  void addHighlight(Highlight highlight) {
//    window.buffer.highlights.add(highlight);
//  }
//
//  void removeHighlight(Highlight highlight) {
//    window.buffer.highlights.remove(highlight);
//  }
//
//  // highlight groups
//
//  List<HighlightGroup> get highlightGroups =>
//      window.buffer.highlightGroups.all.toList();
//  void registerHighlightGroup(HighlightGroup group) {
//    window.buffer.highlightGroups.register(group);
//  }
//
//  void unregisterHighlightGroup(String groupName) {
//    window.buffer.highlightGroups.remove(groupName);
//  }
//
//  // diagnostics
//  List<Diagnostic> get diagnostics => window.buffer.diagnostics.all.toList();
//  void registerDiagnostic(Diagnostic diagnostic) {
//    window.buffer.diagnostics.addDiagnostic(diagnostic);
//  }
//
//  void unregisterDiagnostic(Diagnostic diagnostic) {
//    window.buffer.diagnostics.removeDiagnostic(diagnostic);
//  }
//}
