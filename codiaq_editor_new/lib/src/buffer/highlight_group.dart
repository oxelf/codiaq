import 'package:codiaq_editor/src/buffer/event.dart';
import 'package:flutter/widgets.dart';
import "buffer.dart";

class HighlightGroup {
  final String name;
  final Color? textColor;
  final Color? backgroundColor;
  final int priority;

  HighlightGroup({
    required this.name,
    this.textColor,
    this.backgroundColor,
    required this.priority,
  });
}

class HighlightGroupManager {
  final Map<String, HighlightGroup> _groups = {};

  HighlightGroupManager();

  void register(HighlightGroup group) {
    _groups[group.name] = group;
    //buffer.events.emit(BufferEventType.highlight.index);
  }

  void registerMany(List<HighlightGroup> groups) {
    for (var group in groups) {
      _groups[group.name] = group;
    }
    //buffer.events.emit(BufferEventType.highlight.index);
  }

  void remove(String name) {
    _groups.remove(name);
    //buffer.events.emit(BufferEventType.highlight.index);
  }

  HighlightGroup? get(String name) => _groups[name];

  void clear() {
    _groups.clear();
    //buffer.events.emit(BufferEventType.highlight.index);
  }

  Iterable<HighlightGroup> get all => _groups.values;
}
