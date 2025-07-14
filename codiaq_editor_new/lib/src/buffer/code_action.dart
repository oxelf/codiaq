import 'package:codiaq_editor/src/buffer/completion_manager.dart';

class CodeAction {
  final String title;
  final String commandId;
  final List<dynamic> arguments;
  final List<TextEdit>? edits;

  CodeAction({
    required this.title,
    required this.commandId,
    required this.arguments,
    this.edits,
  });

  factory CodeAction.fromJson(Map<String, dynamic> json) {
    final commandField = json['command'];

    String commandId = '';
    List<dynamic> commandArgs = const [];

    if (commandField is String) {
      // Rare case: command is just a plain string
      commandId = commandField;
      commandArgs = json['arguments'] as List<dynamic>? ?? [];
    } else if (commandField is Map<String, dynamic>) {
      // Normal case: command is a map
      commandId = commandField['command'] as String? ?? '';
      commandArgs = commandField['arguments'] as List<dynamic>? ?? [];
    }

    // Parse edits (if present)
    List<TextEdit>? edits;
    final edit = json['edit'];
    if (edit is Map<String, dynamic>) {
      final docChanges = edit['documentChanges'] as List<dynamic>?;
      if (docChanges != null && docChanges.isNotEmpty) {
        edits =
            docChanges.expand((change) {
              final editsList = change['edits'] as List<dynamic>? ?? [];
              return editsList.map(
                (e) => TextEdit.fromJson(e as Map<String, dynamic>),
              );
            }).toList();
      }
    }

    return CodeAction(
      title: json['title'] as String,
      commandId: commandId,
      arguments: commandArgs,
      edits: edits,
    );
  }
}
