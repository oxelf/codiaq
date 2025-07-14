import 'package:codiaq_editor/src/actions/action.dart';
import 'package:codiaq_editor/src/actions/keyboard_shortcut.dart';

import 'default_actions.dart';

class KeymapManager {
  final Map<KeyboardShortcut, List<EditorAction>> _keymap = {};

  KeymapManager({Map<KeyboardShortcut, List<EditorAction>>? initialKeymap}) {
    if (initialKeymap != null) _keymap.addAll(initialKeymap);
  }

  void registerShortcut(KeyboardShortcut shortcut, EditorAction action) {
    if (_keymap.containsKey(shortcut)) {
      _keymap[shortcut]!.add(action);
    } else {
      _keymap[shortcut] = [action];
    }
  }

  void registerAllShortcuts(
    Map<KeyboardShortcut, List<EditorAction>> shortcuts,
  ) {
    for (var entry in shortcuts.entries) {
      for (var action in entry.value) {
        registerShortcut(entry.key, action);
      }
    }
  }

  void unregisterShortcut(KeyboardShortcut shortcut, EditorAction action) {
    if (_keymap.containsKey(shortcut)) {
      _keymap[shortcut]!.remove(action);
      if (_keymap[shortcut]!.isEmpty) {
        _keymap.remove(shortcut);
      }
    }
  }

  void unregisterById(String actionId) {
    for (var shortcut in _keymap.keys.toList()) {
      _keymap[shortcut]!.removeWhere(
        (action) => action.actionIdentifier == actionId,
      );
      if (_keymap[shortcut]!.isEmpty) {
        _keymap.remove(shortcut);
      }
    }
  }

  List<EditorAction> getActionsForShortcut(KeyboardShortcut shortcut) {
    return _keymap[shortcut] ?? [];
  }
}
