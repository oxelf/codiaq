import 'dart:async';

import 'package:codiaq_editor/codiaq_editor.dart';
import 'package:codiaq_editor/src/actions/keymap_manager.dart';
import 'package:codiaq_editor/src/buffer/breakpoint.dart';
import 'package:codiaq_editor/src/buffer/completion_manager.dart';
import 'package:codiaq_editor/src/buffer/gutter_manager.dart';
import 'package:codiaq_editor/src/buffer/highlighter.dart';
import 'package:codiaq_editor/src/buffer/popup.dart';
import 'package:codiaq_editor/src/buffer/search.dart';
import 'package:codiaq_editor/src/input/input_handler.dart';
import 'package:codiaq_editor/src/input/vim_adapter.dart';
import 'package:codiaq_editor/src/tree_sitter/ts_buf.dart';
import 'package:codiaq_editor/src/ui/light_bulb.dart';
import 'package:codiaq_editor/src/window/viewport.dart' as vp;
import 'package:codiaq_editor/src/ui/hover_popup.dart';
import 'package:flutter/widgets.dart';

import '../window/cursor.dart';
import '../window/selection.dart';
import 'code_action.dart';
import 'id.dart';
import 'lines.dart';
import 'lsp_manager.dart';
import 'marks.dart';
import 'undo.dart';
import 'viewport.dart';

class Buffer {
  int lspVersion = 2;
  final int id;

  bool isModified = false;
  bool isReadOnly = false;

  late final UndoTree undoTree = UndoTree(this);
  // TODO: implement marks
  final BufferMarks marks = BufferMarks();

  late final LineList lines = LineList(this);
  final BufferEvents events = BufferEvents();
  late final HighlightStore highlights = HighlightStore(this);
  late final DiagnosticManager diagnostics = DiagnosticManager(this);
  late final HighlightGroupManager highlightGroups;
  late final lsp = LspManager(this);
  late final PopupManager popupManager = PopupManager(this);
  late BreakpointManager breakpointManager = BreakpointManager(this);
  late final BufferViewport viewport = BufferViewport(this, 0, 20);
  late final CompletionManager completions = CompletionManager(this);
  late final SearchManager search = SearchManager(this);
  late HighlightsManager highlightsManager = HighlightsManager(this);
  late VimAdapter vim = VimAdapter(this);
  late InputHandler inputHandler = InputHandler(this);
  final FocusNode focusNode = FocusNode();
  late final GutterManager gutter = GutterManager(this);
  EditorTheme theme;
  late final KeymapManager keymapManager;
  late final BufferTS ts = BufferTS(buffer: this);
  CursorPosition cursor = CursorPosition(0, 0);
  Selection selection = Selection();
  CursorPosition? latestMousePosition;
  Offset? latestMouseOffset;
  CursorPosition? lastCursorPosition;
  Timer? _hoverTimer;

  int get maxLineLength => lines.maxLineLength;

  String filetype;
  String path = "";

  Buffer({
    this.theme = const EditorTheme(),
    List<String> initialLines = const [],
    this.filetype = "plain_text",
    HighlightGroupManager? hgMgr,
  }) : id = BufferId.next() {
    if (hgMgr != null) {
      highlightGroups = hgMgr;
    } else {
      highlightGroups = HighlightGroupManager();
    }
    highlightsManager = HighlightsManager(this);
    print("HighlightsManager initialized for buffer $id");
    lines.setLines(initialLines);
    events.addListener((event) async {
      if (event.type == BufferEventType.cursor.index) {
        print('Cursor event received: ${cursor.line}, ${cursor.column}');
        var line = cursor.line;
        var col = cursor.column;
        if (lastCursorPosition != null &&
            (lastCursorPosition!.line != line ||
                lastCursorPosition!.column != col)) {
          gutter.remove(lastCursorPosition!.line);
          var codeActions = await lsp.codeActionAtCursor(cursor);
          if (codeActions.isEmpty) {
            print('No code actions available for line $line');
            return;
          }
          print('Code actions available for line $line: $codeActions');
          gutter.add(
            line,
            LightBulbWidget(
              buffer: this,
              codeActions: codeActions,
              position: CursorPosition(line, 0),
            ),
          );
        }
        lastCursorPosition = cursor;
        return;
      }
      if (event.type == BufferEventType.hover.index) {
        var line = event.payload!['line'] as int;
        var col = event.payload!['col'] as int;
        var offset = event.payload!['offset'] as Offset;

        if (latestMouseOffset == null ||
            (offset - latestMouseOffset!).distance > 5) {
          latestMouseOffset = offset;
          latestMousePosition = CursorPosition(line, col);
          _hoverTimer?.cancel();
          _hoverTimer = Timer(const Duration(milliseconds: 600), () {
            triggerHover(line, col, checkMouse: true);
          });
        }
      }
    });
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
      } else {
        _hoverTimer?.cancel();
        latestMousePosition = null;
        latestMouseOffset = null;
      }
    });
  }

  int cursorOffset() {
    var lines = this.lines.getLines(0, this.lines.length);
    if (cursor.line < 0 || cursor.line >= lines.length) {
      return 0;
    }
    if (cursor.column < 0 || cursor.column > lines[cursor.line].length) {
      return 0;
    }
    int offset = 0;
    for (int i = 0; i < cursor.line; i++) {
      offset += lines[i].length + 1; // +1 for the newline character
    }
    offset += cursor.column; // Add the column offset in the current line
    return offset;
  }

  Future<void> triggerHover(
    int line,
    int col, {
    bool checkMouse = false,
  }) async {
    if (checkMouse) {
      if (latestMousePosition == null) return;
      if (latestMousePosition!.line != line ||
          latestMousePosition!.column != col) {
        print('Mouse position changed, ignoring hover request');
        return;
      }
    }

    var ignoreCharacters = [
      "<",
      ">",
      "=",
      ":",
      ";",
      ",",
      ".",
      "?",
      "!",
      "'",
      '"',
      "(",
      ")",
      "{",
      "}",
      "[",
      "]",
    ];
    // if we are on a bracket, dont hover
    var lineText = lines.get(latestMousePosition!.line);
    if (lineText.trim().isEmpty) return;
    if (lineText.length <= latestMousePosition!.column) return;
    if (ignoreCharacters.contains(lineText[latestMousePosition!.column])) {
      print('Hover cancelled due to bracket at position');
      return;
    }
    var response = await lsp.hover(line, col);
    if (response == null) {
      print('No hover response received');
      return;
    }
    var diagnosticsForLine = diagnostics.diagnosticsForLine(line);
    Diagnostic? diagnosticForPos;
    var diagnosticForPosIndex = diagnosticsForLine.indexWhere(
      (d) => d.line == line && d.startCol <= col && d.endCol >= col,
    );
    List<CodeAction> codeActions = [];
    if (diagnosticForPosIndex != -1) {
      diagnosticForPos = diagnosticsForLine[diagnosticForPosIndex];
      codeActions = await lsp.codeActionAtCursor(
        cursor,
        diagnostic: diagnosticForPos,
      );
    }
    var key = GlobalKey();
    popupManager.addPopup(
      Popup(
        zIndex: 1,
        key: key,
        type: "hover",
        content: HoverPopup(
          key: key,
          buffer: this,
          codeActions: codeActions,
          hoverInfo: response["contents"] as String?,
          diagnostic: diagnosticForPos,
          hoverPosition: CursorPosition(line, col),
        ),
        position: CursorPosition(line, col),
      ),
    );
    events.emit(BufferEventType.popupInserted.index);
  }

  List<String> getLinesInViewport(vp.Viewport viewport) {
    final start = viewport.topLine;
    final end = (start + viewport.height).clamp(0, lines.length);
    return lines.getLines(start, end);
  }

  void setFiletype(String newFiletype) {
    filetype = newFiletype;
    events.emit(BufferEventType.fileTypeChanged.index, {
      'filetype': newFiletype,
    });
  }

  void setCursorPosition(int line, int column) {
    cursor = CursorPosition(line, column);
    events.emit(BufferEventType.cursor.index, {'line': line, 'column': column});
  }

  void moveCursorLeft() {
    if (cursor.column > 0) {
      cursor = CursorPosition(cursor.line, cursor.column - 1);
    } else if (cursor.line > 0) {
      cursor = CursorPosition(
        cursor.line - 1,
        lines.get(cursor.line - 1).length,
      );
    }
    events.emit(BufferEventType.cursor.index, {
      'line': cursor.line,
      'column': cursor.column,
    });
  }

  void moveCursorRight() {
    if (cursor.column < lines.get(cursor.line).length) {
      cursor = CursorPosition(cursor.line, cursor.column + 1);
    } else if (cursor.line < lines.length - 1) {
      cursor = CursorPosition(cursor.line + 1, 0);
    }
    events.emit(BufferEventType.cursor.index, {
      'line': cursor.line,
      'column': cursor.column,
    });
  }

  void moveCursorUp() {
    if (cursor.line > 0) {
      cursor = CursorPosition(cursor.line - 1, cursor.column);
      if (cursor.column > lines.get(cursor.line).length) {
        cursor = CursorPosition(cursor.line, lines.get(cursor.line).length);
      }
    }
    events.emit(BufferEventType.cursor.index, {
      'line': cursor.line,
      'column': cursor.column,
    });
  }

  void moveCursorDown() {
    if (cursor.line < lines.length - 1) {
      cursor = CursorPosition(cursor.line + 1, cursor.column);
      if (cursor.column > lines.get(cursor.line).length) {
        cursor = CursorPosition(cursor.line, lines.get(cursor.line).length);
      }
    }
    events.emit(BufferEventType.cursor.index, {
      'line': cursor.line,
      'column': cursor.column,
    });
  }

  void setSelection(Selection newSelection) {
    selection = newSelection;
    events.emit(BufferEventType.selection.index, {
      'start': newSelection.start,
      'end': newSelection.end,
    });
  }

  void clearSelection() {
    selection.clear();
    events.emit(BufferEventType.selection.index, {'start': null, 'end': null});
  }

  List<String> getLines() => lines.snapshot();
}
