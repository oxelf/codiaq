import 'package:codiaq_editor/src/input/custom_text_edit.dart';
import 'package:codiaq_editor/src/ui/search_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../buffer/buffer.dart';
import '../buffer/event.dart';
import '../buffer/popup.dart';
import '../window/cursor.dart';
import '../window/selection.dart';
import 'buffer_painter.dart';
import 'buffer_renderer.dart';
import 'gutter_widget.dart';

class BufferWidget extends StatefulWidget {
  final Buffer buffer;
  final bool expand;
  final bool renderFullHeight;
  const BufferWidget({
    super.key,
    required this.buffer,
    this.expand = true,
    this.renderFullHeight = false,
  });

  @override
  State<BufferWidget> createState() => _BufferWidgetState();
}

class _BufferWidgetState extends State<BufferWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = widget.buffer.theme;
    return BufferRenderer(
      buffer: widget.buffer,
      expand: widget.expand,
      renderFullHeight: widget.renderFullHeight,
    );
  }
}
