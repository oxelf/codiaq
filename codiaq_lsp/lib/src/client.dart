import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:codiaq_lsp/src/protocol/protocol_generated.dart';
import 'message_parser.dart';

typedef LspHandlerFunc =
    Future<dynamic> Function(String method, dynamic params);

abstract class LspClient {
  final String serverId;
  final InitializeParams initializationOptions;

  final Map<String, List<LspHandlerFunc>> _handlers = {};

  // A stream controller to broadcast incoming messages from the server.
  // Other parts of your editor can listen to this stream.
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();

  // To track request IDs and match them with responses.
  int _nextRequestId = 1;
  final Map<int, Completer<dynamic>> _pendingRequests = {};

  LspClient({this.serverId = "unknown", required this.initializationOptions});

  /// A stream of messages received from the language server.
  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  /// Starts the language server client and establishes a connection.
  ///
  /// This method should handle the specifics of the connection type
  /// (e.g., spawning a process, connecting a socket). Once connected, it
  /// should begin listening for incoming messages.
  Future<void> start();

  void on(String method, LspHandlerFunc handler) {
    if (_handlers.containsKey(method)) {
      throw ArgumentError('Handler for $method already exists.');
    }
    if (_handlers[method] == null) {
      _handlers[method] = [];
    }
    _handlers[method]!.add(handler);
  }

  void removeHandler(String method, LspHandlerFunc handler) {
    if (_handlers.containsKey(method)) {
      _handlers[method]!.remove(handler);
      if (_handlers[method]!.isEmpty) {
        _handlers.remove(method);
      }
    }
  }

  /// Sends the 'initialize' request to the language server.
  /// This is the first request sent after the connection is established.
  Future<Map<String, dynamic>> initialize() async {
    var result = await sendRawRequest(
      'initialize',
      initializationOptions.toJson(),
    );
    sendRawNotification('initialized', {});

    messages.listen((message) {
      dynamic params = message['params'];
      var method = message['method'];
      switch (method) {
        case "textDocument/publishDiagnostics":
          if (params is Map<String, dynamic>) {
            params = PublishDiagnosticsParams.fromJson(params);
          }
          break;
        case "window/logMessage":
          if (params is Map<String, dynamic>) {
            params = LogMessageParams.fromJson(params);
          }
          break;
        case "window/showMessage":
          if (params is Map<String, dynamic>) {
            params = ShowMessageParams.fromJson(params);
          }
          break;
        case "window/showDocument":
          if (params is Map<String, dynamic>) {
            params = ShowDocumentParams.fromJson(params);
          }
          break;
        case "window/workDoneProgress/create":
          if (params is Map<String, dynamic>) {
            params = WorkDoneProgressCreateParams.fromJson(params);
          }
          break;
        case "window/workDoneProgress/cancel":
          if (params is Map<String, dynamic>) {
            params = WorkDoneProgressCancelParams.fromJson(params);
          }
          break;
        case "textDocument/hover":
          if (params is Map<String, dynamic>) {
            params = Hover.fromJson(params);
          }
          break;
        case "textDocument/completion":
          if (params is Map<String, dynamic>) {
            params = CompletionItem.fromJson(params);
          }
          break;
        case "textDocument/signatureHelp":
          if (params is Map<String, dynamic>) {
            params = SignatureHelp.fromJson(params);
          }
          break;
        case "textDocument/definition":
          if (params is Map<String, dynamic>) {
            params = Location.fromJson(params);
          }
          break;
        case "textDocument/references":
          if (params is Map<String, dynamic>) {
            params = Location.fromJson(params);
          }
          break;
        case "textDocument/documentSymbol":
          if (params is Map<String, dynamic>) {
            params = DocumentSymbol.fromJson(params);
          }
          break;
        case "textDocument/codeAction":
          if (params is Map<String, dynamic>) {
            params = CodeActionParams.fromJson(params);
          }
          break;
        case "textDocument/codeLens":
          if (params is Map<String, dynamic>) {
            params = CodeLens.fromJson(params);
          }
          break;
        case "textDocument/documentHighlight":
          if (params is Map<String, dynamic>) {
            params = DocumentHighlight.fromJson(params);
          }
          break;
        case "textDocument/formatting":
          if (params is Map<String, dynamic>) {
            params = DocumentFormattingParams.fromJson(params);
          }
          break;
        case "textDocument/rangeFormatting":
          if (params is Map<String, dynamic>) {
            params = DocumentRangeFormattingParams.fromJson(params);
          }
          break;
        case "textDocument/rename":
          if (params is Map<String, dynamic>) {
            params = RenameParams.fromJson(params);
          }
          break;
        case "textDocument/prepareRename":
          if (params is Map<String, dynamic>) {
            params = PrepareRenameParams.fromJson(params);
          }
          break;
        case "textDocument/implementation":
          if (params is Map<String, dynamic>) {
            params = ImplementationParams.fromJson(params);
          }
          break;
        case "textDocument/documentLink":
          if (params is Map<String, dynamic>) {
            params = DocumentLink.fromJson(params);
          }
          break;
        case "textDocument/foldingRange":
          if (params is Map<String, dynamic>) {
            params = FoldingRangeParams.fromJson(params);
          }
          break;
        case "textDocument/selectionRange":
          if (params is Map<String, dynamic>) {
            params = SelectionRangeParams.fromJson(params);
          }
          break;
      }

      var handlers = _handlers[message['method']];
      for (var handler in handlers ?? []) {
        handler(message['method'], message['params']);
      }
    });
    return result;
  }

  /// Attaches the client to a specific editor buffer.
  ///
  /// This signifies that the client is now responsible for handling
  /// LSP features for this buffer. It will typically send a
  /// `textDocument/didOpen` notification.
  //void attach(Buffer buffer) {
  //  if (_attachedBuffers.add(buffer)) {
  //    sendNotification('textDocument/didOpen', {
  //      'textDocument': {
  //        'uri': Uri.file(buffer.path).toString(),
  //        'languageId': 'dart', // This should be dynamic based on file type
  //        'version': 1,
  //        'text': buffer.lines.toString(),
  //      },
  //    });
  //    print('Attached client $serverId to buffer ${buffer.id}');
  //  }
  //}

  /// Detaches the client from a buffer.
  ///
  /// This will  send a `textDocument/didClose` notification.
  //void detach(Buffer buffer) {
  //  if (_attachedBuffers.remove(buffer)) {
  //    sendNotification('textDocument/didClose', {
  //      'textDocument': {'uri': Uri.file(buffer.path).toString()},
  //    });
  //    print('Detached client $serverId from buffer ${buffer.id}');
  //  }
  //}

  Future<dynamic> sendRawRequest(String method, Map<String, dynamic> params) {
    final id = _nextRequestId++;
    final request = {
      'jsonrpc': '2.0',
      'id': id,
      'method': method,
      'params': params,
    };

    final completer = Completer<dynamic>();
    _pendingRequests[id] = completer;

    _sendMessage(request);
    return completer.future;
  }

  Future<dynamic> sendRawResponse(int id, Map<String, dynamic> result) {
    final request = {'jsonrpc': '2.0', 'id': id, 'result': result};

    final completer = Completer<dynamic>();
    _pendingRequests[id] = completer;

    _sendMessage(request);
    return completer.future;
  }

  void sendRawNotification(String method, Map<String, dynamic> params) {
    final notification = {'jsonrpc': '2.0', 'method': method, 'params': params};
    _sendMessage(notification);
  }

  Future<void> shutdown() async {
    await sendRawRequest('shutdown', {});
    sendRawNotification('exit', {});
    await _messageController.close();
    _pendingRequests.clear();
  }

  void _sendMessage(Map<String, dynamic> message);

  void _handleIncomingData(dynamic rawMessage) {
    try {
      final decoded = jsonDecode(rawMessage);
      if (decoded is! Map<String, dynamic>) {
        // Not a map, ignore or log
        return;
      }

      if (decoded.containsKey('id') &&
          _pendingRequests.containsKey(decoded['id'])) {
        // It's a response
        final id = decoded['id'];
        final completer = _pendingRequests.remove(id);
        if (decoded.containsKey('error')) {
          completer?.completeError(LspError.fromJson(decoded['error']));
        } else {
          dynamic result;
          try {
            if (decoded.containsKey('result')) {
              result = decoded['result'];
            }
          } catch (e) {
            result = decoded;
          }
          completer?.complete(result);
        }
      } else {
        // It's a Notification or Request
        _messageController.add(decoded);
      }
    } catch (e) {
      print("Error parsing LSP message: $e");
    }
  }
}

/// An LSP client that communicates with a language server over standard I/O.
///
/// This is common for locally installed language servers that are spawned
/// as child processes.
class StdioLspClient extends LspClient {
  final String command;
  final List<String> args;
  Process? _process;

  StdioLspClient({
    required this.command,
    this.args = const [],
    required String serverId,
    required InitializeParams initializationOptions,
  }) : super(serverId: serverId, initializationOptions: initializationOptions);

  @override
  Future<void> start() async {
    try {
      _process = await Process.start(command, args, runInShell: true);

      _process!.stdout
          .transform(LspMessageParser())
          .listen(
            _handleIncomingData,
            onDone: () => print('$serverId stdout closed.'),
            onError: (e) => print('Error on $serverId stdout: $e'),
          );

      _process!.stderr
          .transform(const Utf8Decoder())
          .listen((data) => print('[$serverId STDERR] $data'));

      print('$serverId process started with PID: ${_process!.pid}');
    } catch (e) {
      print('Failed to start language server $serverId: $e');
      rethrow;
    }
  }

  @override
  void _sendMessage(Map<String, dynamic> message) {
    if (_process == null) {
      throw StateError('Client not started. Cannot send message.');
    }
    final content = jsonEncode(message);
    final messageWithHeader =
        'Content-Length: ${content.length}\r\n\r\n$content';
    _process!.stdin.write(messageWithHeader);
  }

  @override
  Future<void> shutdown() async {
    await super.shutdown();
    _process?.kill();
  }
}

/// An LSP client that communicates with a language server over a TCP socket.
class TcpLspClient extends LspClient {
  final String host;
  final int port;
  Socket? _socket;

  TcpLspClient({
    required this.host,
    required this.port,
    required String serverId,
    required InitializeParams initializationOptions,
  }) : super(serverId: serverId, initializationOptions: initializationOptions);

  @override
  Future<void> start() async {
    try {
      _socket = await Socket.connect(host, port);
      _socket!
          .cast<List<int>>()
          .transform<String>(LspMessageParser())
          .listen(
            _handleIncomingData,
            onDone: () => print('Socket to $serverId closed.'),
            onError: (e) => print('Error on $serverId socket: $e'),
          );
      print('Connected to $serverId at $host:$port');
    } catch (e) {
      print('Failed to connect to language server $serverId: $e');
      rethrow;
    }
  }

  @override
  void _sendMessage(Map<String, dynamic> message) {
    if (_socket == null) {
      throw StateError('Client not started. Cannot send message.');
    }
    final content = jsonEncode(message);
    final messageWithHeader =
        'Content-Length: ${content.length}\r\n\r\n$content';
    _socket!.write(messageWithHeader);
  }

  @override
  Future<void> shutdown() async {
    await super.shutdown();
    await _socket?.close();
  }
}

/// An LSP client that communicates with a language server over WebSockets.
/// Note: This would require a package like `web_socket_channel`.
//class WebSocketLspClient extends LspClient {
//  final Uri uri;
//  // WebSocketChannel? _channel;
//
//  WebSocketLspClient({
//    required this.uri,
//    required String serverId,
//    Map<String, dynamic>? initializationOptions,
//  }) : super(serverId: serverId, initializationOptions: initializationOptions);
//
//  @override
//  Future<void> start() async {
//    print(
//      "WebSocketLspClient is a placeholder and requires a websocket package.",
//    );
//    // Example with web_socket_channel:
//    // _channel = WebSocketChannel.connect(uri);
//    // _channel!.stream.listen(_handleIncomingData,
//    //   onDone: () => print('WebSocket to $serverId closed.'),
//    //   onError: (e) => print('Error on $serverId WebSocket: $e'),
//    // );
//    // print('Connected to $serverId via WebSocket at $uri');
//  }
//
//  @override
//  void _sendMessage(Map<String, dynamic> message) {
//    // if (_channel == null) {
//    //   throw StateError('Client not started. Cannot send message.');
//    // }
//    // _channel!.sink.add(jsonEncode(message));
//  }
//
//  @override
//  Future<void> shutdown() async {
//    await super.shutdown();
//    // _channel?.sink.close();
//  }
//}

// A placeholder for LSP error objects.
class LspError extends Error {
  final int code;
  final String message;
  final dynamic data;

  LspError(this.code, this.message, [this.data]);

  factory LspError.fromJson(Map<String, dynamic> json) {
    return LspError(json['code'], json['message'], json['data']);
  }

  @override
  String toString() => 'LspError(code: $code, message: $message)';
}
