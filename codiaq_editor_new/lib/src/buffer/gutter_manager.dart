import 'package:flutter/widgets.dart';

import '../../codiaq_editor.dart';

class GutterManager {
  final Map<int, Widget> gutterWidgets = {};
  final Buffer buffer;

  GutterManager(this.buffer);

  void add(int line, Widget widget) {
    gutterWidgets[line] = widget;
    buffer.events.emit(BufferEventType.gutter.index, {
      'line': line,
      'widget': widget,
    });
  }

  Widget get(int line) {
    return gutterWidgets[line] ?? const SizedBox.shrink();
  }

  void remove(int line) {
    if (gutterWidgets.containsKey(line)) {
      gutterWidgets.remove(line);
      buffer.events.emit(BufferEventType.gutter.index, {
        'line': line,
        'widget': null,
      });
    }
  }

  void clear() {
    gutterWidgets.clear();
    buffer.events.emit(BufferEventType.gutter.index, {
      'line': null,
      'widget': null,
    });
  }
}
