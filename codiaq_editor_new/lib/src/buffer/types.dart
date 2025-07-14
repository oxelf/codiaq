class EditorTextPosition {
  final int line;
  final int column;

  EditorTextPosition(this.line, this.column);

  Map<String, dynamic> toJson() {
    return {'line': line, 'character': column};
  }

  factory EditorTextPosition.fromJson(Map<String, dynamic> json) {
    return EditorTextPosition(json['line'] as int, json['character'] as int);
  }
}

class EditorTextRange {
  final EditorTextPosition start;
  final EditorTextPosition end;
  final String? text;

  EditorTextRange({required this.start, required this.end, this.text});

  Map<String, dynamic> toJson() {
    return {'start': start.toJson(), 'end': end.toJson(), 'text': text};
  }

  factory EditorTextRange.fromJson(Map<String, dynamic> json) {
    return EditorTextRange(
      start: EditorTextPosition(
        json['start']['line'] as int,
        json['start']['character'] as int,
      ),
      end: EditorTextPosition(
        json['end']['line'] as int,
        json['end']['character'] as int,
      ),
      text: json['text'] as String?,
    );
  }
}
