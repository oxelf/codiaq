import 'package:codiaq_editor/codiaq_editor.dart';

import '../languages/all.dart';
import 'highlight.dart';
import 'node.dart';

List<Highlight> highlight(
  String language,
  String code, {
  bool autoDetect = false,
}) {
  final highlighter = Highlighter();
  highlighter.registerLanguages(allLanguages);

  final result = highlighter.parse(
    code,
    language: language,
    autoDetection: autoDetect,
  );
  final nodes = result.nodes;

  final highlights = <Highlight>[];
  int currentLine = 1;
  int currentCol = 1;

  // NEW, CORRECTED TRAVERSE FUNCTION
  void traverse(Node node, [String? parentClassName]) {
    final currentClassName = node.className ?? parentClassName;

    // Handle leaf nodes that contain the actual text
    if (node.value != null) {
      final lines = node.value!.split('\n');
      for (int i = 0; i < lines.length; i++) {
        final lineText = lines[i];
        if (lineText.isNotEmpty) {
          // Only create a highlight if there is a group/className associated with this text.
          if (currentClassName != null) {
            highlights.add(
              Highlight(
                currentLine,
                currentCol,
                currentCol + lineText.length,
                currentClassName,
              ),
            );
          }
          // ALWAYS advance the column counter for all text
          currentCol += lineText.length;
        }

        if (i < lines.length - 1) {
          currentLine++;
          currentCol = 1;
        }
      }
    }

    // Handle container nodes by recursing into their children
    if (node.children != null) {
      for (final child in node.children!) {
        // Pass down the parent's class name so children can inherit it
        traverse(child, currentClassName);
      }
    }
  }

  if (nodes != null) {
    for (final node in nodes) {
      traverse(node); // Initial call with no parent class
    }
  }

  return highlights;
}
