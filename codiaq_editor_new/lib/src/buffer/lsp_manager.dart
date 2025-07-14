import 'package:codiaq_editor/codiaq_editor.dart';
import 'package:codiaq_editor/src/buffer/code_action.dart';

import '../window/cursor.dart';

class LspManager {
  List<LspClient> _clients = [];
  List<Diagnostic> _diagnostics = [];
  int lspVersion = 2;
  final Buffer buffer;

  LspManager(this.buffer) {
    buffer.events.addListener((event) async {
      if (event.type == BufferEventType.modified.index ||
          event.type == BufferEventType.inserted.index ||
          event.type == BufferEventType.deleted.index) {
        await _notifyDidChange();
      }
    });
  }

  Future<(CursorPosition, CursorPosition)?> getRangeForCursor(
    CursorPosition cursor,
  ) async {
    for (var client in _clients) {
      try {
        var response = await client.sendRequest("textDocument/hover", {
          'textDocument': {'uri': Uri.file(buffer.path).toString()},
          'position': {'line': cursor.line, 'character': cursor.column},
        });
        if (response != null && response['range'] != null) {
          var startRange = CursorPosition(
            response['range']['start']['line'],
            response['range']['start']['character'],
          );
          var endRange = CursorPosition(
            response['range']['end']['line'],
            response['range']['end']['character'],
          );
          return (startRange, endRange);
        }
      } catch (e) {
        print("LSP hover request failed: $e");
      }
    }
    return null;
  }

  void registerClient(LspClient client) {
    _clients.add(client);
    client.attach(buffer);
    client.messages.listen((message) {
      print('RECEIVED message from LSP server: ${message['method']}');
      if (message["method"] == "window/showMessage") {
        String messageType =
            message['params']['type'] == 1
                ? 'Error'
                : message['params']['type'] == 2
                ? 'Warning'
                : 'Info';
        String content = message['params']['message'];
        print('LSP Message: [$messageType] $content');
      }
      if (message["method"] == "workspace/applyEdit") {
        print('Received workspace/applyEdit from server: ${message}');
        final edit = message['params']["edit"];
        final documentChanges = edit['documentChanges'] as List<dynamic>?;
        if (documentChanges == null) {
          print('No document changes found in applyEdit');
          return;
        }
        for (var change in documentChanges) {
          var document = change['textDocument'] as Map<String, dynamic>;
          var edits = change['edits'] as List<dynamic>;
          if (edits.isEmpty) continue;
          for (var edit in edits) {
            var start = CursorPosition(
              edit['range']['start']['line'],
              edit['range']['start']['character'],
            );
            var end = CursorPosition(
              edit['range']['end']['line'],
              edit['range']['end']['character'],
            );
            var text = edit['newText'] as String;
            print(
              'Applying edit to document ${document['uri']}: $start to $end with text "$text"',
            );
            buffer.lines.replaceRange(start, end, text);
            buffer.events.emit(BufferEventType.modified.index, {
              'start': start,
              'end': end,
              'text': text,
            });
            print("responding with applied to id ${message['id']}");
            client.sendResponse(message['id'], {'applied': true});
            Future.delayed(
              const Duration(milliseconds: 100),
              () => buffer.events.emit(BufferEventType.highlight.index),
            ); // Allow buffer to process the change
          }
        }
      }
      if (message['method'] == 'textDocument/publishDiagnostics') {
        final params = message['params'];
        final uri = params['uri'];
        final diagnosticsList = params['diagnostics'] as List;

        if (uri != Uri.file(buffer.path).toString()) {
          print(
            'Received diagnostics for a different document: $uri, expected: ${Uri.file(buffer.path)}',
          );
          return;
        }

        for (final dia in _diagnostics) {
          buffer.diagnostics.removeDiagnostic(dia);
        }

        for (final dia in diagnosticsList) {
          var diagnostic = Diagnostic.fromLspDiagnostic(
            dia as Map<String, dynamic>,
          );
          _diagnostics.add(diagnostic);
          buffer.diagnostics.addDiagnostic(diagnostic);
        }
      }
    });
    buffer.events.emit(BufferEventType.lspAttach.index, {'client': client});
  }

  Future<Map<String, dynamic>?> hover(int line, int column) async {
    for (var client in _clients) {
      try {
        var response = await client.sendRequest("textDocument/hover", {
          'textDocument': {'uri': Uri.file(buffer.path).toString()},
          'position': {'line': line, 'character': column},
        });
        return response;
      } catch (e) {
        print('LSP hover request failed: $e');
      }
    }
    return null;
  }

  Future<dynamic> completion(
    int line,
    int column, {
    String? triggerCharacter,
  }) async {
    for (var client in _clients) {
      try {
        var params = {
          'textDocument': {'uri': Uri.file(buffer.path).toString()},
          'position': {'line': line, 'character': column},
        };
        if (triggerCharacter != null) {
          params['context'] = {
            'triggerKind': 1,
            'triggerCharacter': triggerCharacter,
          };
        }
        var response = await client.sendRequest(
          "textDocument/completion",
          params,
        );
        //print(
        //  "LSP completion response type: ${response.runtimeType}, response: $response",
        //);
        return response;
      } catch (e) {
        print('LSP completion request failed: $e');
      }
    }
    return null;
  }

  Future<List<CodeAction>> codeActionAtCursor(
    CursorPosition cursor, {
    Diagnostic? diagnostic,
  }) async {
    for (var client in _clients) {
      try {
        var wordAtCursor = buffer.lines.wordAtPos(cursor);
        print(
          "LSP code action at cursor: $cursor, word: ${wordAtCursor.text}, range: ${wordAtCursor.start.line}:${wordAtCursor.start.column}-${wordAtCursor.end.line}:${wordAtCursor.end.column}",
        );
        var response = await client.sendRequest("textDocument/codeAction", {
          'textDocument': {'uri': Uri.file(buffer.path).toString()},
          'range': wordAtCursor.toJson(),
          'context': {
            'diagnostics':
                diagnostic != null ? [diagnostic.toLspDiagnostic()] : [],
          },
        });
        print(
          "code action response type: ${response.runtimeType}, response: $response",
        );
        List<CodeAction> codeActions = [];
        for (var action in response) {
          codeActions.add(CodeAction.fromJson(action));
        }
        return codeActions;
      } catch (e) {
        print('LSP code action request failed: $e');
      }
    }
    return [];
  }

  //Future<List<CodeAction>> codeActionForDiagnostic(
  //  Diagnostic diagnostic,
  //) async {
  //  for (var client in _clients) {
  //    try {
  //      var lspDiagnostic = diagnostic.toLspDiagnostic();
  //
  //      var response = await client.sendRequest("textDocument/codeAction", {
  //        'textDocument': {'uri': Uri.file(buffer.path).toString()},
  //        'range': lspDiagnostic['range'],
  //        'context': {
  //          'diagnostics': [diagnostic.toLspDiagnostic()],
  //        },
  //      });
  //      print(
  //        "code action response type: ${response.runtimeType}, response: $response",
  //      );
  //      List<CodeAction> codeActions = [];
  //      for (var action in response) {
  //        codeActions.add(CodeAction.fromJson(action));
  //      }
  //      return codeActions;
  //    } catch (e) {
  //      print('LSP code action request failed: $e');
  //    }
  //  }
  //  return [];
  //}

  Future<void> executeCodeAction(CodeAction codeAction) async {
    print('Executing CODE action: ${codeAction.title}');
    print("edits is not null: ${codeAction.edits != null}");
    print(
      "commandId: ${codeAction.commandId}, arguments: ${codeAction.arguments}",
    );
    if (codeAction.edits != null) {
      for (var edit in codeAction.edits!) {
        var start = edit.rangeStart;
        var end = edit.rangeEnd;
        if (start != null && end != null) {
          buffer.lines.replaceRange(start, end, edit.newText);
          // buffer.setCursorPosition(end.line, end.column);
          print(
            'APPLIED code action: ${codeAction.title} at range ${start.line}:${start.column} to ${end.line}:${end.column} with text "${edit.newText}"',
          );

          final insertedText = edit.newText;
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
      }
      return;
    }
    for (var client in _clients) {
      try {
        await client.sendRequest("workspace/executeCommand", {
          'command': codeAction.commandId,
          'arguments': codeAction.arguments,
        });
      } catch (e) {
        print('LSP execute code action failed: $e');
      }
    }
  }

  Future<void> _notifyDidChange() async {
    for (var client in _clients) {
      try {
        client.sendNotification("textDocument/didChange", {
          'textDocument': {
            'uri': Uri.file(buffer.path).toString(),
            "version": lspVersion++,
          },
          'contentChanges': [
            {
              'text': buffer.lines.toString(),
              //"range": {
              //  'start': {'line': 0, 'character': 0},
              //  'end': {
              //    'line': buffer.lines.length - 1,
              //    'character': buffer.lines.get(buffer.lines.length - 1).length,
              //  },
              //},
            },
          ],
        });
      } catch (e) {
        print('LSP didChange notification failed: $e');
      }
    }
  }
}
