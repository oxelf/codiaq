import "buffer.dart";
import "event.dart";

class Highlight {
  final int line;
  final int startCol;
  final int endCol;
  final String group;

  Highlight(this.line, this.startCol, this.endCol, this.group);
}

class HighlightStore {
  final List<Highlight> _highlights = [];
  final Buffer buffer;

  HighlightStore(this.buffer);

  void add(Highlight h) {
    _highlights.add(h);
    buffer.events.emit(BufferEventType.highlight.index, {"highlight": h});
  }

  void remove(Highlight h) {
    _highlights.remove(h);
    buffer.events.emit(BufferEventType.highlight.index, {
      "highlight": h,
      "removed": true,
    });
  }

  void clear() {
    _highlights.clear();
    buffer.events.emit(BufferEventType.highlight.index, {"cleared": true});
  }

  List<Highlight> getHighlightsForLine(int line) {
    return _highlights.where((h) => h.line == line).toList();
  }
}

class HighlightSpan {
  final int start;
  final int end;
  final String group;

  HighlightSpan(this.start, this.end, this.group);
}
