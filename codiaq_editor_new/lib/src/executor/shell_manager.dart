import 'package:codiaq_editor/src/executor/shell_entry.dart';
import 'package:flutter/foundation.dart';

import 'terminal_shell.dart';

class ShellManager extends ChangeNotifier {
  final List<ShellEntry> _shells = [];
  ShellEntry? _activeShell;
  int _nextId = 0;
  String? workingDirectory;

  List<ShellEntry> get shells => List.unmodifiable(_shells);
  ShellEntry? get activeShell => _activeShell;

  ShellManager({this.workingDirectory}) {
    newShell(name: 'Local');
  }

  Future<void> newShell({String? name}) async {
    final shell =
        TerminalShell.platform(); // Replace with your actual shell implementation
    shell.workingDirectory = workingDirectory;
    await shell.start();

    final entry = ShellEntry(
      id: _nextId++,
      name: name ?? 'Terminal ${_shells.length + 1}',
      shell: shell,
    );

    _shells.add(entry);
    _activeShell ??= entry;
    notifyListeners();
  }

  void closeShell(int id) {
    final index = _shells.indexWhere((s) => s.id == id);
    if (index == -1) return;

    final removed = _shells.removeAt(index);
    removed.shell.dispose();

    if (_activeShell?.id == id) {
      _activeShell = _shells.isNotEmpty ? _shells.first : null;
    }

    notifyListeners();
  }

  void setActiveShell(int id) {
    final shell = _shells.firstWhere(
      (s) => s.id == id,
      orElse: () => _activeShell!,
    );
    _activeShell = shell;
    notifyListeners();
  }

  void renameShell(int id, String newName) {
    final shell = _shells.firstWhere(
      (s) => s.id == id,
      orElse: () => _activeShell!,
    );
    shell.name = newName;
    notifyListeners();
  }
}
