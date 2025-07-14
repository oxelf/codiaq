class BufferMarks {
  final Map<String, (int line, int col)> _marks = {};

  void setMark(String name, int line, int col) {
    _marks[name] = (line, col);
  }

  (int, int)? getMark(String name) => _marks[name];
}
