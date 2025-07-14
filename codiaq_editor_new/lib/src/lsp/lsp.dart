import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:codiaq_editor/src/buffer/buffer.dart';
import 'package:flutter/foundation.dart';

import '../buffer/diagnostic.dart';
import 'message_parser.dart';

abstract class LspClient {
  final Map<String, List<Diagnostic>> uriDiagnostics = {};
  final String serverId;
  final Map<String, dynamic>? initializationOptions;

  // A stream controller to broadcast incoming messages from the server.
  // Other parts of your editor can listen to this stream.
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();

  // A set of buffers this client is currently attached to.
  final Set<Buffer> _attachedBuffers = {};

  // To track request IDs and match them with responses.
  int _nextRequestId = 1;
  final Map<int, Completer<dynamic>> _pendingRequests = {};

  LspClient({required this.serverId, this.initializationOptions});

  /// A stream of messages received from the language server.
  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  /// Returns an unmodifiable view of the attached buffers.
  Set<Buffer> get attachedBuffers => UnmodifiableSetView(_attachedBuffers);

  /// Starts the language server client and establishes a connection.
  ///
  /// This method should handle the specifics of the connection type
  /// (e.g., spawning a process, connecting a socket). Once connected, it
  /// should begin listening for incoming messages.
  Future<void> start();

  /// Sends the 'initialize' request to the language server.
  /// This is the first request sent after the connection is established.
  Future<Map<String, dynamic>> initialize({
    required String rootUri,
    required Map<String, dynamic> capabilities,
    required int? pid,
  }) async {
    // In a real implementation, you'd construct a proper 'InitializeParams' object.
    var result = await sendRequest('initialize', {
      'processId': pid,
      'rootUri': rootUri,
      'capabilities': capabilities,
      'initializationOptions': initializationOptions,
    });
    sendNotification('initialized', {});

    messages.listen((message) {
      if (message['method'] == 'textDocument/publishDiagnostics') {
        final params = message['params'];
        final uri = params['uri'];
        final diagnosticsList = params['diagnostics'] as List;

        var newUriDiagnostics = <String, List<Diagnostic>>{};

        for (final dia in diagnosticsList) {
          var diagnostic = Diagnostic.fromLspDiagnostic(
            dia as Map<String, dynamic>,
          );

          if (newUriDiagnostics.containsKey(uri)) {
            newUriDiagnostics[uri]!.add(diagnostic);
          } else {
            newUriDiagnostics[uri] = [diagnostic];
          }
        }

        uriDiagnostics[uri] = newUriDiagnostics[uri] ?? <Diagnostic>[];
      }
    });
    return result;
  }

  /// Attaches the client to a specific editor buffer.
  ///
  /// This signifies that the client is now responsible for handling
  /// LSP features for this buffer. It will typically send a
  /// `textDocument/didOpen` notification.
  void attach(Buffer buffer) {
    if (_attachedBuffers.add(buffer)) {
      sendNotification('textDocument/didOpen', {
        'textDocument': {
          'uri': Uri.file(buffer.path).toString(),
          'languageId': 'dart', // This should be dynamic based on file type
          'version': 1,
          'text': buffer.lines.toString(),
        },
      });
      print('Attached client $serverId to buffer ${buffer.id}');
    }
  }

  /// Detaches the client from a buffer.
  ///
  /// This will  send a `textDocument/didClose` notification.
  void detach(Buffer buffer) {
    if (_attachedBuffers.remove(buffer)) {
      sendNotification('textDocument/didClose', {
        'textDocument': {'uri': Uri.file(buffer.path).toString()},
      });
      print('Detached client $serverId from buffer ${buffer.id}');
    }
  }

  Future<dynamic> sendRequest(String method, Map<String, dynamic> params) {
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

  Future<dynamic> sendResponse(int id, Map<String, dynamic> result) {
    final request = {'jsonrpc': '2.0', 'id': id, 'result': result};

    final completer = Completer<dynamic>();
    _pendingRequests[id] = completer;

    _sendMessage(request);
    return completer.future;
  }

  void sendNotification(String method, Map<String, dynamic> params) {
    final notification = {'jsonrpc': '2.0', 'method': method, 'params': params};
    _sendMessage(notification);
  }

  Future<void> shutdown() async {
    await sendRequest('shutdown', {});
    sendNotification('exit', {});
    await _messageController.close();
    _pendingRequests.clear();
  }

  void _sendMessage(Map<String, dynamic> message);

  void _handleIncomingData(String rawMessage) {
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
    Map<String, dynamic>? initializationOptions,
  }) : super(serverId: serverId, initializationOptions: initializationOptions);

  @override
  Future<void> start() async {
    try {
      _process = await Process.start(command, args);

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
    Map<String, dynamic>? initializationOptions,
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
class WebSocketLspClient extends LspClient {
  final Uri uri;
  // WebSocketChannel? _channel;

  WebSocketLspClient({
    required this.uri,
    required String serverId,
    Map<String, dynamic>? initializationOptions,
  }) : super(serverId: serverId, initializationOptions: initializationOptions);

  @override
  Future<void> start() async {
    print(
      "WebSocketLspClient is a placeholder and requires a websocket package.",
    );
    // Example with web_socket_channel:
    // _channel = WebSocketChannel.connect(uri);
    // _channel!.stream.listen(_handleIncomingData,
    //   onDone: () => print('WebSocket to $serverId closed.'),
    //   onError: (e) => print('Error on $serverId WebSocket: $e'),
    // );
    // print('Connected to $serverId via WebSocket at $uri');
  }

  @override
  void _sendMessage(Map<String, dynamic> message) {
    // if (_channel == null) {
    //   throw StateError('Client not started. Cannot send message.');
    // }
    // _channel!.sink.add(jsonEncode(message));
  }

  @override
  Future<void> shutdown() async {
    await super.shutdown();
    // _channel?.sink.close();
  }
}

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
