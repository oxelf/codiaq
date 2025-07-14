//import 'package:codiaq_editor/codiaq_editor.dart';
//import 'package:codiaq_editor/src/highlighting/src/api.dart';
//import 'package:codiaq_editor/src/plugin/window_plugin.dart';
//
//class HighlightPlugin extends WindowPluginBase {
//  HighlightPlugin();
//
//  List<Highlight> highlights = [];
//
//  @override
//  void init() {
//    _highlight();
//  }
//
//  @override
//  void onTyping() {
//    _highlight();
//  }
//
//  Future<void> _highlight() async {
//    for (var highlight in this.highlights) {
//      api.removeHighlight(highlight);
//    }
//    this.highlights.clear();
//    List<Highlight> highlights = highlight("dart", api.lines.join("\n"));
//    print("Found ${highlights.length} highlights");
//    for (var highlight in highlights) {
//      var h = Highlight(
//        highlight.line - 1,
//        highlight.startCol - 1,
//        highlight.endCol - 1,
//        highlight.group,
//      );
//      api.addHighlight(h);
//      this.highlights.add(h);
//      api.dispatchEvent(BufferEventType.highlight.index, {"highlight": h});
//    }
//    print("Highlighted");
//  }
//
//  @override
//  void cleanup() {}
//}
