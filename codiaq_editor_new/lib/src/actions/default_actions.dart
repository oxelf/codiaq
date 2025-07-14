import 'package:flutter/services.dart';

import '../../codiaq_editor.dart';
import '../window/cursor.dart';
import '../window/selection.dart';

Map<KeyboardShortcut, List<EditorAction>> macosDefaultKeymap = {
  KeyboardShortcut(
    firstKeyStroke: KeyStroke.fromLogicalKey(
      LogicalKeyboardKey.keyC,
      modifiers: Modifiers.construct(meta: true),
    ),
  ): [ActionBufferCopy()],

  KeyboardShortcut(
    firstKeyStroke: KeyStroke.fromLogicalKey(
      LogicalKeyboardKey.keyX,
      modifiers: Modifiers.construct(meta: true),
    ),
  ): [ActionBufferCut()],

  KeyboardShortcut(
    firstKeyStroke: KeyStroke.fromLogicalKey(
      LogicalKeyboardKey.keyV,
      modifiers: Modifiers.construct(meta: true),
    ),
  ): [ActionBufferPaste()],
  KeyboardShortcut(
    firstKeyStroke: KeyStroke.fromLogicalKey(LogicalKeyboardKey.backspace),
  ): [ActionBufferDelete()],
  KeyboardShortcut(
    firstKeyStroke: KeyStroke.fromLogicalKey(LogicalKeyboardKey.tab),
  ): [ActionBufferTab()],

  KeyboardShortcut(
    firstKeyStroke: KeyStroke.fromLogicalKey(LogicalKeyboardKey.enter),
  ): [ActionBufferEnter()],

  KeyboardShortcut(
    firstKeyStroke: KeyStroke.fromLogicalKey(
      LogicalKeyboardKey.arrowLeft,
      modifiers: Modifiers.construct(shift: true),
    ),
  ): [
    ActionMoveLeft(
      selecting: true,
      actionIdentifier: "buffer.moveLeft.selecting",
    ),
  ],

  KeyboardShortcut(
    firstKeyStroke: KeyStroke.fromLogicalKey(LogicalKeyboardKey.arrowLeft),
  ): [ActionMoveLeft()],

  KeyboardShortcut(
    firstKeyStroke: KeyStroke.fromLogicalKey(
      LogicalKeyboardKey.arrowRight,
      modifiers: Modifiers.construct(shift: true),
    ),
  ): [
    ActionMoveRight(
      selecting: true,
      actionIdentifier: "buffer.moveRight.selecting",
    ),
  ],

  KeyboardShortcut(
    firstKeyStroke: KeyStroke.fromLogicalKey(LogicalKeyboardKey.arrowRight),
  ): [ActionMoveRight()],

  KeyboardShortcut(
    firstKeyStroke: KeyStroke.fromLogicalKey(
      LogicalKeyboardKey.arrowUp,
      modifiers: Modifiers.construct(shift: true),
    ),
  ): [
    ActionMoveUp(selecting: true, actionIdentifier: "buffer.moveUp.selecting"),
  ],

  KeyboardShortcut(
    firstKeyStroke: KeyStroke.fromLogicalKey(LogicalKeyboardKey.arrowUp),
  ): [ActionMoveUp()],

  KeyboardShortcut(
    firstKeyStroke: KeyStroke.fromLogicalKey(
      LogicalKeyboardKey.arrowDown,
      modifiers: Modifiers.construct(shift: true),
    ),
  ): [
    ActionMoveDown(
      selecting: true,
      actionIdentifier: "buffer.moveDown.selecting",
    ),
  ],

  KeyboardShortcut(
    firstKeyStroke: KeyStroke.fromLogicalKey(LogicalKeyboardKey.arrowDown),
  ): [ActionMoveDown()],
  KeyboardShortcut(
    firstKeyStroke: KeyStroke.fromLogicalKey(
      LogicalKeyboardKey.arrowLeft,
      modifiers: Modifiers.construct(meta: true),
    ),
  ): [ActionMoveLineStart()],
  // Meta + Shift + ArrowLeft for move to line start with selection
  KeyboardShortcut(
    firstKeyStroke: KeyStroke.fromLogicalKey(
      LogicalKeyboardKey.arrowLeft,
      modifiers: Modifiers.construct(meta: true, shift: true),
    ),
  ): [
    ActionMoveLineStart(
      selecting: true,
      actionIdentifier: "buffer.moveLineStart.selecting",
    ),
  ],
  // Meta + ArrowRight for move to line end
  KeyboardShortcut(
    firstKeyStroke: KeyStroke.fromLogicalKey(
      LogicalKeyboardKey.arrowRight,
      modifiers: Modifiers.construct(meta: true),
    ),
  ): [ActionMoveLineEnd()],
  // Meta + Shift + ArrowRight for move to line end with selection
  KeyboardShortcut(
    firstKeyStroke: KeyStroke.fromLogicalKey(
      LogicalKeyboardKey.arrowRight,
      modifiers: Modifiers.construct(meta: true, shift: true),
    ),
  ): [
    ActionMoveLineEnd(
      selecting: true,
      actionIdentifier: "buffer.moveLineEnd.selecting",
    ),
  ],

  KeyboardShortcut(
    firstKeyStroke: KeyStroke.fromLogicalKey(LogicalKeyboardKey.escape),
  ): [ActionBufferUnselect()],

  KeyboardShortcut(
    firstKeyStroke: KeyStroke.fromLogicalKey(
      LogicalKeyboardKey.keyZ,
      modifiers: Modifiers.construct(meta: true),
    ),
  ): [ActionBufferUndo()],

  KeyboardShortcut(
    firstKeyStroke: KeyStroke.fromLogicalKey(
      LogicalKeyboardKey.keyY,
      modifiers: Modifiers.construct(meta: true),
    ),
  ): [ActionBufferRedo()],
};

class CopyAction extends EditorAction {
  CopyAction({super.actionIdentifier = "buffer.copy"});

  @override
  void performAction(ActionEvent event) {
    print("COPY ACTION PERFORMED");
  }
}

class ActionBufferDelete extends EditorAction {
  ActionBufferDelete({super.actionIdentifier = "buffer.delete"});

  @override
  void performAction(ActionEvent event) {
    if (event.buffer == null) {
      return;
    }
    final buffer = event.buffer!;
    if (buffer.selection.isActive) {
      var newCursorPosition = buffer.selection.start;
      if (buffer.selection.end!.line < buffer.selection.start!.line) {
        newCursorPosition = buffer.selection.end;
      }
      if (buffer.selection.end!.line == buffer.selection.start!.line &&
          buffer.selection.end!.column < buffer.selection.start!.column) {
        newCursorPosition = buffer.selection.end;
      }
      buffer.lines.deleteRange(buffer.selection.start!, buffer.selection.end!);
      buffer.selection.clear();
      buffer.setCursorPosition(
        newCursorPosition!.line,
        newCursorPosition.column,
      );
      return;
    }
    if (buffer.cursor.column == 0 && buffer.cursor.line > 0) {
      final previousLine = buffer.lines[buffer.cursor.line - 1];
      final currentLine = buffer.lines[buffer.cursor.line];
      buffer.lines[buffer.cursor.line - 1] = previousLine + currentLine;
      buffer.lines.removeAt(buffer.cursor.line);
      buffer.setCursorPosition(buffer.cursor.line - 1, previousLine.length);
      return;
    }
    buffer.lines.deleteRange(
      buffer.cursor,
      CursorPosition(buffer.cursor.line, buffer.cursor.column - 1),
    );
    buffer.setCursorPosition(buffer.cursor.line, buffer.cursor.column - 1);
  }
}

class ActionBufferTab extends EditorAction {
  ActionBufferTab({super.actionIdentifier = "buffer.tab"});

  @override
  void performAction(ActionEvent event) {
    if (event.buffer == null) {
      return;
    }
    final buffer = event.buffer!;
    //if (buffer.selection.isActive) {
    // Handle tabbing selected text
    //final selectedText = buffer.getSelectedText();
    //final indentedText = selectedText
    //    .split('\n')
    //    .map((line) => '\t$line')
    //    .join('\n');
    //buffer.replaceSelection(indentedText);
    //} else {
    // Insert a tab character at the cursor position
    buffer.lines.insertAt(
      buffer.cursor.line,
      buffer.cursor.column,
      " " * buffer.theme.tabSize,
    );
    buffer.setCursorPosition(
      buffer.cursor.line,
      buffer.cursor.column + buffer.theme.tabSize,
    );
    //}
  }
}

class ActionBufferEnter extends EditorAction {
  ActionBufferEnter({super.actionIdentifier = "buffer.enter"});

  @override
  void performAction(ActionEvent event) {
    if (event.buffer == null) {
      return;
    }
    final buffer = event.buffer!;
    final currentLine = buffer.lines[buffer.cursor.line];
    final textAfterCursor = currentLine.substring(buffer.cursor.column);
    final newLineText = currentLine.substring(0, buffer.cursor.column);

    // Insert new line
    buffer.lines.insert(buffer.cursor.line + 1, textAfterCursor);

    // Update the current line
    buffer.lines[buffer.cursor.line] = newLineText;

    // Move cursor to the start of the new line
    buffer.setCursorPosition(buffer.cursor.line + 1, 0);
  }
}

//void moveLeft({bool selecting = false}) {
//  final newPos = CursorPosition(
//    buffer.cursor.line,
//    buffer.cursor.column > 0 ? buffer.cursor.column - 1 : 0,
//  );
//  if (selecting) {
//    _extendSelection(newPos);
//  } else {
//    buffer.selection.clear();
//    buffer.setCursorPosition(newPos.line, newPos.column);
//  }
//}
//
//void moveRight({bool selecting = false}) {
//  final line = buffer.lines[buffer.cursor.line];
//  final newPos = CursorPosition(
//    buffer.cursor.line,
//    buffer.cursor.column < line.length
//        ? buffer.cursor.column + 1
//        : line.length,
//  );
//  if (selecting) {
//    _extendSelection(newPos);
//  } else {
//    buffer.selection.clear();
//    buffer.setCursorPosition(newPos.line, newPos.column);
//  }
//}
//
//void moveUp({bool selecting = false}) {
//  final newLine = buffer.cursor.line > 0 ? buffer.cursor.line - 1 : 0;
//  final newCol = clampPosition(buffer.cursor.column, buffer.lines[newLine]);
//  final newPos = CursorPosition(newLine, newCol);
//  if (selecting) {
//    _extendSelection(newPos);
//  } else {
//    buffer.selection.clear();
//    buffer.setCursorPosition(newPos.line, newPos.column);
//  }
//}
//
//void moveDown({bool selecting = false}) {
//  final newLine =
//      buffer.cursor.line < buffer.lines.length - 1
//          ? buffer.cursor.line + 1
//          : buffer.lines.length - 1;
//  final newCol = clampPosition(buffer.cursor.column, buffer.lines[newLine]);
//  final newPos = CursorPosition(newLine, newCol);
//  if (selecting) {
//    _extendSelection(newPos);
//  } else {
//    buffer.selection.clear();
//    buffer.setCursorPosition(newPos.line, newPos.column);
//  }
//}

//void _extendSelection(CursorPosition newPos) {
//  final start = buffer.selection.start ?? buffer.cursor;
//  final end = newPos;
//
//  buffer.setSelection(Selection(start: start, end: end));
//  buffer.setCursorPosition(newPos.line, newPos.column);
//}
int clampPosition(int column, String line) {
  return column.clamp(0, line.length);
}

class ActionMoveLeft extends EditorAction {
  final bool selecting;

  ActionMoveLeft({
    this.selecting = false,
    super.actionIdentifier = "buffer.moveLeft",
  });

  @override
  void performAction(ActionEvent event) {
    if (event.buffer == null) return;
    final buffer = event.buffer!;

    final newPos = CursorPosition(
      buffer.cursor.line,
      buffer.cursor.column > 0 ? buffer.cursor.column - 1 : 0,
    );

    if (selecting || buffer.selection.isActive) {
      final start =
          buffer.selection.isActive
              ? buffer.selection.start ?? buffer.cursor
              : buffer.cursor;
      buffer.setSelection(Selection(start: start, end: newPos));
    } else {
      buffer.selection.clear();
    }

    buffer.setCursorPosition(newPos.line, newPos.column);
  }
}

class ActionMoveRight extends EditorAction {
  final bool selecting;

  ActionMoveRight({
    this.selecting = false,
    super.actionIdentifier = "buffer.moveRight",
  });

  @override
  void performAction(ActionEvent event) {
    if (event.buffer == null) return;
    final buffer = event.buffer!;
    final line = buffer.lines[buffer.cursor.line];

    final newPos = CursorPosition(
      buffer.cursor.line,
      buffer.cursor.column < line.length
          ? buffer.cursor.column + 1
          : line.length,
    );

    if (selecting || buffer.selection.isActive) {
      final start =
          buffer.selection.isActive
              ? buffer.selection.start ?? buffer.cursor
              : buffer.cursor;
      buffer.setSelection(Selection(start: start, end: newPos));
    } else {
      buffer.selection.clear();
    }

    buffer.setCursorPosition(newPos.line, newPos.column);
  }
}

class ActionMoveUp extends EditorAction {
  final bool selecting;

  ActionMoveUp({
    this.selecting = false,
    super.actionIdentifier = "buffer.moveUp",
  });

  @override
  void performAction(ActionEvent event) {
    if (event.buffer == null) return;
    final buffer = event.buffer!;

    final newLine = buffer.cursor.line > 0 ? buffer.cursor.line - 1 : 0;
    final newCol = clampPosition(buffer.cursor.column, buffer.lines[newLine]);
    final newPos = CursorPosition(newLine, newCol);

    if (selecting || buffer.selection.isActive) {
      final start =
          buffer.selection.isActive
              ? buffer.selection.start ?? buffer.cursor
              : buffer.cursor;
      buffer.setSelection(Selection(start: start, end: newPos));
    } else {
      buffer.selection.clear();
    }

    buffer.setCursorPosition(newPos.line, newPos.column);
  }
}

class ActionMoveDown extends EditorAction {
  final bool selecting;

  ActionMoveDown({
    this.selecting = false,
    super.actionIdentifier = "buffer.moveDown",
  });

  @override
  void performAction(ActionEvent event) {
    if (event.buffer == null) return;
    final buffer = event.buffer!;

    final newLine =
        buffer.cursor.line < buffer.lines.length - 1
            ? buffer.cursor.line + 1
            : buffer.lines.length - 1;
    final newCol = clampPosition(buffer.cursor.column, buffer.lines[newLine]);
    final newPos = CursorPosition(newLine, newCol);

    if (selecting || buffer.selection.isActive) {
      final start =
          buffer.selection.isActive
              ? buffer.selection.start ?? buffer.cursor
              : buffer.cursor;
      buffer.setSelection(Selection(start: start, end: newPos));
    } else {
      buffer.selection.clear();
    }

    buffer.setCursorPosition(newPos.line, newPos.column);
  }
}

class ActionMoveLineStart extends EditorAction {
  final bool selecting;

  ActionMoveLineStart({
    this.selecting = false,
    super.actionIdentifier = "buffer.moveLineStart",
  });

  @override
  void performAction(ActionEvent event) {
    if (event.buffer == null) return;
    final buffer = event.buffer!;

    final newPos = CursorPosition(buffer.cursor.line, 0);

    if (selecting || buffer.selection.isActive) {
      final start =
          buffer.selection.isActive
              ? buffer.selection.start ?? buffer.cursor
              : buffer.cursor;
      buffer.setSelection(Selection(start: start, end: newPos));
    } else {
      buffer.selection.clear();
    }

    buffer.setCursorPosition(newPos.line, newPos.column);
  }
}

class ActionMoveLineEnd extends EditorAction {
  final bool selecting;

  ActionMoveLineEnd({
    this.selecting = false,
    super.actionIdentifier = "buffer.moveLineEnd",
  });

  @override
  void performAction(ActionEvent event) {
    if (event.buffer == null) return;
    final buffer = event.buffer!;
    final line = buffer.lines[buffer.cursor.line];

    final newPos = CursorPosition(buffer.cursor.line, line.length);

    if (selecting || buffer.selection.isActive) {
      final start =
          buffer.selection.isActive
              ? buffer.selection.start ?? buffer.cursor
              : buffer.cursor;
      buffer.setSelection(Selection(start: start, end: newPos));
    } else {
      buffer.selection.clear();
    }

    buffer.setCursorPosition(newPos.line, newPos.column);
  }
}

class ActionBufferUnselect extends EditorAction {
  ActionBufferUnselect({super.actionIdentifier = "buffer.unselect"});

  @override
  void performAction(ActionEvent event) {
    if (event.buffer == null) return;
    final buffer = event.buffer!;
    if (buffer.selection.isActive) {
      buffer.clearSelection();
    }
  }
}

class ActionBufferUndo extends EditorAction {
  ActionBufferUndo({super.actionIdentifier = "buffer.undo"});

  @override
  void performAction(ActionEvent event) {
    if (event.buffer == null) return;
    final buffer = event.buffer!;
    buffer.undoTree.undo();
  }
}

class ActionBufferRedo extends EditorAction {
  ActionBufferRedo({super.actionIdentifier = "buffer.redo"});

  @override
  void performAction(ActionEvent event) {
    if (event.buffer == null) return;
    final buffer = event.buffer!;
    buffer.undoTree.redo();
  }
}

class ActionBufferCopy extends EditorAction {
  ActionBufferCopy({super.actionIdentifier = "buffer.copy"});

  @override
  void performAction(ActionEvent event) {
    if (event.buffer == null) return;
    final buffer = event.buffer!;
    if (buffer.selection.isActive) {
      final selectedText = buffer.lines.getRangeText(
        buffer.selection.start!,
        buffer.selection.end!,
      );
      Clipboard.setData(ClipboardData(text: selectedText));
      print("Copied to clipboard: $selectedText");
    } else {
      print("No text selected to copy.");
    }
  }
}

class ActionBufferCut extends EditorAction {
  ActionBufferCut({super.actionIdentifier = "buffer.cut"});

  @override
  void performAction(ActionEvent event) {
    if (event.buffer == null) return;
    final buffer = event.buffer!;
    if (buffer.selection.isActive) {
      final selectedText = buffer.lines.getRangeText(
        buffer.selection.start!,
        buffer.selection.end!,
      );
      Clipboard.setData(ClipboardData(text: selectedText));
      print("Cut to clipboard: $selectedText");
      buffer.lines.deleteRange(buffer.selection.start!, buffer.selection.end!);
      CursorPosition newCursorPosition = buffer.selection.start!;
      if (buffer.selection.end!.line < buffer.selection.start!.line ||
          (buffer.selection.end!.line == buffer.selection.start!.line &&
              buffer.selection.end!.column < buffer.selection.start!.column)) {
        newCursorPosition = buffer.selection.end!;
      }
      buffer.setCursorPosition(
        newCursorPosition.line,
        newCursorPosition.column,
      );
      buffer.clearSelection();
    } else {
      print("No text selected to cut.");
    }
  }
}

class ActionBufferPaste extends EditorAction {
  ActionBufferPaste({super.actionIdentifier = "buffer.paste"});

  @override
  void performAction(ActionEvent event) async {
    if (event.buffer == null) return;
    final buffer = event.buffer!;
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text != null) {
      final text = clipboardData.text!;
      buffer.lines.insertAt(buffer.cursor.line, buffer.cursor.column, text);
      var lineLength = text.split('\n').length;
      var lastLineLength = text.split('\n').lastOrNull?.length ?? 0;
      buffer.setCursorPosition(
        buffer.cursor.line + lineLength - 1,
        lastLineLength,
      );
    } else {
      print("Clipboard is empty or does not contain text.");
    }
  }
}
