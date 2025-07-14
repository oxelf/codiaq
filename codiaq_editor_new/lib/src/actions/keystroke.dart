import 'package:flutter/services.dart';

class KeyStroke {
  final int keyCode;
  final int modifiers; // e.g., Meta, Ctrl, Shift as bitflags
  final String? keyChar;
  final bool onKeyRelease;

  static final Map<String, KeyStroke> _cache = {};

  const KeyStroke._({
    required this.keyCode,
    required this.modifiers,
    this.keyChar,
    this.onKeyRelease = false,
  });

  /// Factory for keyCode + modifiers
  factory KeyStroke.fromKeyCode(
    int keyCode, {
    int modifiers = 0,
    bool onKeyRelease = false,
  }) {
    final key = 'keyCode:$keyCode;mod:$modifiers;release:$onKeyRelease';
    return _cache.putIfAbsent(
      key,
      () => KeyStroke._(
        keyCode: keyCode,
        modifiers: modifiers,
        onKeyRelease: onKeyRelease,
      ),
    );
  }

  factory KeyStroke.fromLogicalKey(
    LogicalKeyboardKey key, {
    int modifiers = 0,
    bool onKeyRelease = false,
  }) {
    final keyCode = key.keyId;
    var keyChar = key.keyLabel;
    if (modifiers & Modifiers.shift == 0) {
      keyChar = key.keyLabel.toLowerCase();
    }
    final keyString = 'keyCode:$keyCode;mod:$modifiers;release:$onKeyRelease';
    return _cache.putIfAbsent(
      keyString,
      () => KeyStroke._(
        keyCode: keyCode,
        modifiers: modifiers,
        keyChar: keyChar,
        onKeyRelease: onKeyRelease,
      ),
    );
  }

  /// Factory for keyChar (e.g., 'a', 'A', etc.)
  factory KeyStroke.fromKeyChar(
    String char, {
    int modifiers = 0,
    bool onKeyRelease = false,
  }) {
    if (char.length != 1) {
      throw ArgumentError('Only single characters allowed');
    }
    final key = 'char:$char;mod:$modifiers;release:$onKeyRelease';
    return _cache.putIfAbsent(
      key,
      () => KeyStroke._(
        keyCode: char.codeUnitAt(0),
        modifiers: modifiers,
        keyChar: char,
        onKeyRelease: onKeyRelease,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is KeyStroke &&
      keyCode == other.keyCode &&
      modifiers == other.modifiers &&
      onKeyRelease == other.onKeyRelease &&
      keyChar == other.keyChar;

  @override
  int get hashCode =>
      keyCode.hashCode ^
      modifiers.hashCode ^
      keyChar.hashCode ^
      onKeyRelease.hashCode;

  @override
  String toString() {
    return 'KeyStroke(keyCode: $keyCode, modifiers: $modifiers, keyChar: $keyChar, onKeyRelease: $onKeyRelease)';
  }
}

class Modifiers {
  static const int shift = 1 << 0;
  static const int ctrl = 1 << 1;
  static const int alt = 1 << 2;
  static const int meta = 1 << 3;

  static String describe(int mods) {
    final parts = <String>[];
    if ((mods & shift) != 0) parts.add('Shift');
    if ((mods & ctrl) != 0) parts.add('Ctrl');
    if ((mods & alt) != 0) parts.add('Alt');
    if ((mods & meta) != 0) parts.add('Meta');
    return parts.join('+');
  }

  static int construct({
    bool shift = false,
    bool ctrl = false,
    bool alt = false,
    bool meta = false,
  }) {
    int mods = 0;
    if (shift) mods |= Modifiers.shift;
    if (ctrl) mods |= Modifiers.ctrl;
    if (alt) mods |= Modifiers.alt;
    if (meta) mods |= Modifiers.meta;
    return mods;
  }
}
