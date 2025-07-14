import 'package:codiaq_editor/codiaq_editor.dart';
import 'package:codiaq_editor/src/tree_sitter/tree_sitter_base.dart';

class BufferTS {
  final Buffer buffer;
  final TreeSitterLanguage? language;
  final Parser parser;

  BufferTS({required this.buffer, this.language, Parser? parser})
    : parser = parser ?? Parser() {
    if (language != null) {
      parser?.setLanguage(language!);
    }
  }
}
