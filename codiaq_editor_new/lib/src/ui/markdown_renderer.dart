import 'package:codiaq_editor/codiaq_editor.dart';
import 'package:flutter/material.dart';

class MarkdownRenderer extends StatefulWidget {
  final String markdown;
  final Buffer buffer;

  const MarkdownRenderer({
    super.key,
    required this.markdown,
    required this.buffer,
  });

  @override
  State<MarkdownRenderer> createState() => _MarkdownRendererState();
}

class _MarkdownRendererState extends State<MarkdownRenderer> {
  @override
  Widget build(BuildContext context) {
    var theme = widget.buffer.theme;
    final lines = widget.markdown.split('\n');
    final widgets = <Widget>[];
    int i = 0;

    while (i < lines.length) {
      final line = lines[i].trim();

      // Divider
      if (line == '---' || line == '***') {
        widgets.add(const Divider());
        i++;
        continue;
      }
      if (line.startsWith("*")) {
        /// emphasis text, until next * or end of line
        var empasisEnd = line.indexOf('*', 1);
        if (empasisEnd == -1) {
          empasisEnd = line.length;
        }
        widgets.add(buildEmphasisText(line.substring(1, empasisEnd).trim()));
        i++;
        continue;
      }
      // Code block
      else if (line.startsWith('```')) {
        final language = line.length > 3 ? line.substring(3).trim() : '';
        final codeBuffer = <String>[];
        i++;
        while (i < lines.length && !lines[i].trim().startsWith('```')) {
          codeBuffer.add(lines[i]);
          i++;
        }
        widgets.add(_buildCode(codeBuffer.join('\n'), language));
        i++; // skip the ending ```
      }
      // Heading
      else if (line.startsWith('# ')) {
        widgets.add(
          _buildText(
            line.substring(2).trim(),
            style: theme.baseStyle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        i++;
      }
      // List item
      else if (line.startsWith('- ')) {
        widgets.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• '),
              Expanded(child: _buildText(line.substring(2).trim())),
            ],
          ),
        );
        i++;
      }
      // Regular text
      else {
        if (line.isNotEmpty) {
          widgets.add(_buildText(line));
        }
        i++;
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: SelectableRegion(
            selectionControls: MaterialTextSelectionControls(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widgets,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildText(String text, {TextStyle? style}) {
    var theme = widget.buffer.theme;
    return Text(text, style: style ?? theme.baseStyle);
  }

  Widget buildEmphasisText(String text) {
    var theme = widget.buffer.theme;
    return Text(
      text,
      style: theme.baseStyle.copyWith(fontStyle: FontStyle.italic),
    );
  }

  Widget _buildCode(String code, String language) {
    var theme = widget.buffer.theme;
    final buffer = Buffer(
      filetype: language,
      initialLines: code.split('\n'),
      theme: theme,
    );
    var newTheme = theme.copyWith(
      backgroundColor: Colors.transparent,
      lineHighlightColor: Colors.transparent,
      showGutter: false,
    );
    buffer.filetype = language;
    buffer.path = 'markdown_code_block.$language';
    buffer.theme = newTheme;
    for (var h in widget.buffer.highlightGroups.all.toList()) {
      buffer.highlightGroups.register(h);
    }

    return Container(
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
        minHeight: 20,
      ),
      child: BufferWidget(
        buffer: buffer,
        expand: false,
        renderFullHeight: true,
      ),
    );
  }
}
