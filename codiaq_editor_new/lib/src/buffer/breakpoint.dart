import '../../codiaq_editor.dart';

class Breakpoint {
  final int line;

  Breakpoint(this.line);
}

class BreakpointManager {
  final List<Breakpoint> _breakpoints = [];
  final Buffer buffer;

  BreakpointManager(this.buffer);

  void addBreakpoint(int line) {
    if (!_breakpoints.any((bp) => bp.line == line)) {
      _breakpoints.add(Breakpoint(line));
    }
    buffer.events.emit(BufferEventType.breakpoint.index, {
      'breakpoint': Breakpoint(line),
    });
  }

  void removeBreakpoint(int line) {
    _breakpoints.removeWhere((bp) => bp.line == line);
    buffer.events.emit(BufferEventType.breakpoint.index, {
      'breakpoint': Breakpoint(line),
    });
  }

  bool hasBreakpoint(int line) {
    return _breakpoints.any((bp) => bp.line == line);
  }

  List<Breakpoint> get breakpoints => List.unmodifiable(_breakpoints);
}
