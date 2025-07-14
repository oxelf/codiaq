import 'package:flutter/foundation.dart';

import 'tool_window.dart';

class ToolWindowManager extends ChangeNotifier {
  final Map<String, ToolWindow> _windows = {};

  void registerToolWindow(String id, ToolWindow window) {
    _windows[id] = window;
    notifyListeners();
  }

  void unregisterToolWindow(String id) {
    if (_windows.containsKey(id)) {
      _windows.remove(id);
      notifyListeners();
    }
  }

  bool hasToolWindow(String id) => _windows.containsKey(id);

  ToolWindow? getToolWindow(String id) => _windows[id];

  List<ToolWindow> getWindowsAt(Anchor anchor) =>
      _windows.values.where((w) => w.anchor == anchor).toList();

  List<ToolWindow> getWindowsAtVisible(Anchor anchor) =>
      _windows.values.where((w) => w.anchor == anchor && w.isVisible).toList();

  String getId(ToolWindow window) {
    return _windows.entries
        .firstWhere(
          (entry) => entry.value == window,
          orElse: () => MapEntry('', window),
        )
        .key;
  }

  void toggleVisibility(String id) {
    if (_windows.containsKey(id)) {
      _windows[id]!.isVisible = !_windows[id]!.isVisible;
      notifyListeners();
    }
  }
}
