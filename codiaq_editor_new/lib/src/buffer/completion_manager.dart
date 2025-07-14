import 'dart:async';

import 'package:codiaq_editor/src/buffer/popup.dart';
import 'package:codiaq_editor/src/window/cursor.dart';
import 'package:flutter/material.dart';

import '../../codiaq_editor.dart';
import '../ui/completion_popup.dart';

enum CompletionType {
  keyword,
  identifier,
  function,
  className,
  variable,
  constant,
  typeAlias,
  importCompletion,
}

class Completion {
  final CompletionType type;
  final String label;
  final String? detail;
  final int kind;
  final String? documentation;
  final String? insertText;
  final int? insertTextFormat;
  final TextEdit? textEdit;
  final String? filterText;
  final String? sortText;

  const Completion({
    required this.type,
    required this.label,
    this.kind = 0,
    this.detail,
    this.filterText,
    this.sortText,
    this.textEdit,
    this.documentation,
    this.insertText,
    this.insertTextFormat,
  });

  factory Completion.fromJson(Map<String, dynamic> json) {
    return Completion(
      type: CompletionType.variable,
      label: json['label'] as String,
      detail: json['detail'] as String?,
      documentation: json['documentation'] as String?,
      insertText: json['insertText'] as String?,
      insertTextFormat: json['insertTextFormat'] as int?,
      textEdit:
          (json['textEdit'] != null)
              ? TextEdit.fromJson(json['textEdit'])
              : null,
      filterText: json['filterText'] as String?,
      sortText: json['sortText'] as String?,
    );
  }
}

class TextEdit {
  final CursorPosition? rangeStart;
  final CursorPosition? rangeEnd;
  final String newText;
  const TextEdit({this.rangeStart, this.rangeEnd, required this.newText});

  factory TextEdit.fromJson(Map<String, dynamic> json) {
    return TextEdit(
      rangeStart:
          (json["range"] != null)
              ? CursorPosition(
                json['range']['start']['line'],
                json['range']['start']['character'],
              )
              : null,
      rangeEnd:
          (json["range"] != null)
              ? CursorPosition(
                json['range']['end']['line'],
                json['range']['end']['character'],
              )
              : null,
      newText: json['newText'] as String,
    );
  }
}

class CompletionManager {
  StreamController<List<Completion>> _completionsController =
      StreamController<List<Completion>>.broadcast();
  Stream<List<Completion>> get completionsStream =>
      _completionsController.stream;
  List<Completion> _completions = [];
  final Buffer buffer;

  List<Completion> get completions => _completions;

  CompletionManager(this.buffer) {
    buffer.events.addListener((event) async {
      //if (event.type == BufferEventType.modified.index ||
      //    event.type == BufferEventType.inserted.index ||
      //    event.type == BufferEventType.deleted.index) {
      //  var result = buffer.lsp.completion(
      //    buffer.cursor.line,
      //    buffer.cursor.column,
      //  );
      //  print('Completions received: $result');
      //}
    });
  }

  Future<void> applyCompletion(Completion completion) async {
    print(
      'Applying completion: ${completion.sortText} ${completion.label} ${completion.filterText}',
    );
    if (completion.textEdit != null) {
      var start = completion.textEdit!.rangeStart;
      var end = completion.textEdit!.rangeEnd;
      if (start != null && end != null) {
        buffer.lines.replaceRange(start, end, completion.textEdit!.newText);
        // buffer.setCursorPosition(end.line, end.column);
        print(
          'APPLIED completion: ${completion.label} at range ${start.line}:${start.column} to ${end.line}:${end.column} with text "${completion.textEdit!.newText}"',
        );

        final insertedText = completion.textEdit!.newText;
        final lines = insertedText.split('\n');
        final finalLineOffset = lines.last.length;

        final finalLineNumber = start.line + lines.length - 1;
        final finalColumnOffset =
            lines.length == 1
                ? start.column + insertedText.length
                : lines.last.length;
        buffer.setCursorPosition(finalLineNumber, finalColumnOffset);
      } else {
        print('Invalid text edit range for completion: $completion');
      }
    } else if (completion.insertText != null) {
      print("normal insertion completion");
      buffer.lines.insert(buffer.cursor.line, completion.insertText!);
      buffer.setCursorPosition(
        buffer.cursor.line,
        buffer.cursor.column + (completion.insertText?.length ?? 0),
      );
    } else {
      print('No valid text edit or insert text for completion: $completion');
    }

    buffer.events.emit(BufferEventType.modified.index);
  }

  Future<void> updateWithLsp() async {
    var result = await buffer.lsp.completion(
      buffer.cursor.line,
      buffer.cursor.column,
    );
    List<dynamic> jsonCompletions = [];
    try {
      jsonCompletions = result['items'] as List<dynamic>;
    } catch (e) {
      jsonCompletions = result as List<dynamic>;
      print('Error parsing LSP completions: $e');
      return;
    }
    List<Completion> completions =
        jsonCompletions.map((json) {
          return Completion.fromJson(json as Map<String, dynamic>);
        }).toList();
    //completions.sort((a, b) => a.label.length.compareTo(b.label.length));
    _completions = completions;
    if (_completions.isEmpty) {
      buffer.popupManager.removePopupByType("completion");
      return;
    }
    final stateKey = GlobalKey<CompletionPopupState>();
    Popup popup = Popup(
      closeOnExit: false,
      closeOnTapOutside: true,
      key: stateKey,
      zIndex: 4,
      type: "completion",
      content: CompletionPopup(
        key: stateKey,
        buffer: buffer,
        completions: completions,
      ),
      position: CursorPosition(buffer.cursor.line, buffer.cursor.column),
    );
    buffer.popupManager.removePopupByType("completion");
    buffer.popupManager.addPopup(popup);
  }
}
