import 'package:flutter/foundation.dart';

import '../../codiaq_editor.dart';

class ProjectDiagnostics extends ChangeNotifier {
  final Map<String, List<Diagnostic>> _diagnostics;

  ProjectDiagnostics({Map<String, List<Diagnostic>>? diagnostics})
    : _diagnostics = diagnostics ?? {};

  List<Diagnostic> getDiagnosticsForFile(String filePath) {
    return _diagnostics[filePath] ?? [];
  }

  Map<String, List<Diagnostic>> get allDiagnostics => _diagnostics;

  void addDiagnostic(String filePath, Diagnostic diagnostic) {
    if (!_diagnostics.containsKey(filePath)) {
      _diagnostics[filePath] = [];
    }
    _diagnostics[filePath]!.add(diagnostic);
    notifyListeners();
  }

  void removeDiagnostic(String filePath, Diagnostic diagnostic) {
    if (_diagnostics.containsKey(filePath)) {
      _diagnostics[filePath]!.remove(diagnostic);
      if (_diagnostics[filePath]!.isEmpty) {
        _diagnostics.remove(filePath);
      }
      notifyListeners();
    }
  }

  void replaceDiagnostics(String filePath, List<Diagnostic> diagnostics) {
    _diagnostics[filePath] = diagnostics;
    notifyListeners();
  }
}
