import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

/// A stream transformer that parses LSP messages from a byte stream.
/// It handles the 'Content-Length' header and emits complete JSON message strings.
class LspMessageParser extends StreamTransformerBase<List<int>, String> {
  @override
  Stream<String> bind(Stream<List<int>> stream) {
    final controller = StreamController<String>();
    final buffer = BytesBuilder();

    stream.listen(
      (data) {
        buffer.add(data);

        while (true) {
          final currentBytes = buffer.toBytes();
          if (currentBytes.isEmpty) {
            break;
          }

          final headerEndIndex = _findHeaderEnd(currentBytes);

          if (headerEndIndex == -1) {
            // Full headers not yet received, wait for more data
            break;
          }

          final headerStr = utf8.decode(
            currentBytes.sublist(0, headerEndIndex),
          );
          final contentLength = _parseContentLength(headerStr);

          if (contentLength == null) {
            controller.addError(
              StateError(
                "Could not parse Content-Length from headers:\n$headerStr",
              ),
            );
            buffer.clear(); // Clear buffer to prevent getting stuck
            break;
          }

          final totalMessageLength = headerEndIndex + contentLength;
          if (currentBytes.length < totalMessageLength) {
            // Full message body not yet received, wait for more data
            break;
          }

          // We have a full message (headers + body)
          final messageBodyBytes = currentBytes.sublist(
            headerEndIndex,
            totalMessageLength,
          );
          final messageBody = utf8.decode(messageBodyBytes);
          controller.add(messageBody);

          // Remove the processed message from the buffer and continue the loop
          final remainingBytes = currentBytes.sublist(totalMessageLength);
          buffer.clear();
          buffer.add(remainingBytes);
        }
      },
      onError: controller.addError,
      onDone: () {
        if (buffer.isNotEmpty) {
          controller.addError(
            StateError("Stream closed with incomplete data in buffer."),
          );
        }
        controller.close();
      },
    );

    return controller.stream;
  }

  /// Parses the Content-Length from the header string using a regular expression.
  /// This is more robust than splitting by lines.
  int? _parseContentLength(String header) {
    final match = RegExp(
      r'Content-Length: (\d+)',
      caseSensitive: false,
    ).firstMatch(header);
    if (match != null && match.groupCount >= 1) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  /// Finds the end of the HTTP-style header block (\r\n\r\n).
  int _findHeaderEnd(Uint8List bytes) {
    for (int i = 0; i < bytes.length - 3; i++) {
      if (bytes[i] == 13 && // \r
          bytes[i + 1] == 10 && // \n
          bytes[i + 2] == 13 && // \r
          bytes[i + 3] == 10) {
        // \n
        return i + 4;
      }
    }
    return -1;
  }
}
