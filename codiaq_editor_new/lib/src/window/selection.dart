import 'controller.dart';
import 'cursor.dart';

class Selection {
  CursorPosition? start;
  CursorPosition? end;
  EditorMode? mode;

  Selection({this.start, this.end, this.mode});

  bool get isActive => start != null && end != null;

  void clear() {
    start = null;
    end = null;
    mode = null;
  }
}
