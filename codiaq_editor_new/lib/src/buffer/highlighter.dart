import '../../codiaq_editor.dart';
import '../highlighting/src/api.dart';

class HighlightsManager {
  final Buffer buffer;
  List<Highlight> _highlights = [];

  HighlightsManager(this.buffer) {
    print("Initializing HighlightsManager for buffer: ${buffer.filetype}");
    buffer.events.addListener((event) {
      if (event.type == BufferEventType.modified.index ||
          event.type == BufferEventType.inserted.index ||
          event.type == BufferEventType.deleted.index) {
        _updateHighlights();
      }
    });
    _updateHighlights();
  }

  Future<void> _updateHighlights() async {
    print("UPDATING highlights for buffer: ${buffer.filetype}");
    for (var highlight in _highlights) {
      buffer.highlights.remove(highlight);
    }
    _highlights.clear();
    List<Highlight> highlights = highlight(
      buffer.filetype,
      buffer.lines.getText(),
    );
    for (var highlight in highlights) {
      var h = Highlight(
        highlight.line - 1,
        highlight.startCol - 1,
        highlight.endCol - 1,
        highlight.group,
      );
      buffer.highlights.add(h);
      _highlights.add(h);
      buffer.events.emit(BufferEventType.highlight.index, {"highlight": h});
    }
  }
}
