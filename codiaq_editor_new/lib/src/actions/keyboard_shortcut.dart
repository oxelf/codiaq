import 'package:codiaq_editor/src/actions/keystroke.dart';

class KeyboardShortcut {
  final KeyStroke firstKeyStroke;
  final KeyStroke? secondKeyStroke;

  const KeyboardShortcut({required this.firstKeyStroke, this.secondKeyStroke});

  @override
  operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is KeyboardShortcut &&
        other.firstKeyStroke == firstKeyStroke &&
        other.secondKeyStroke == secondKeyStroke;
  }

  @override
  int get hashCode =>
      firstKeyStroke.hashCode ^ (secondKeyStroke?.hashCode ?? 0);
}
