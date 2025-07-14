import "buffer.dart";
import "event.dart";

enum DiagnosticSeverity { error, warning, information, hint }

class Diagnostic {
  final int line;
  final int startCol;
  final int endCol;
  final String message;
  final String documentationUrl;
  final DiagnosticSeverity severity;

  Diagnostic({
    required this.line,
    required this.startCol,
    required this.endCol,
    required this.message,
    required this.severity,
    this.documentationUrl = '',
  });

  factory Diagnostic.fromLspDiagnostic(Map<String, dynamic> lspDiagnostic) {
    final range = lspDiagnostic['range'];
    final codeDescription = lspDiagnostic['codeDescription'] as Map?;

    return Diagnostic(
      line: range['start']['line'] as int,
      startCol: range['start']['character'] as int,
      endCol: range['end']['character'] as int,
      message: lspDiagnostic['message'] as String,
      severity: _mapSeverityFromLsp(lspDiagnostic['severity'] as int?),
      documentationUrl: codeDescription?['href'] as String? ?? '',
    );
  }

  Map<String, dynamic> toLspDiagnostic() {
    return {
      'range': {
        'start': {'line': line, 'character': startCol},
        'end': {'line': line, 'character': endCol},
      },
      'message': message,
      'severity': _mapSeverityToLsp(severity),
      if (documentationUrl.isNotEmpty)
        'codeDescription': {'href': documentationUrl},
    };
  }

  static DiagnosticSeverity _mapSeverityFromLsp(int? severity) {
    switch (severity) {
      case 1:
        return DiagnosticSeverity.error;
      case 2:
        return DiagnosticSeverity.warning;
      case 3:
        return DiagnosticSeverity.information;
      case 4:
        return DiagnosticSeverity.hint;
      default:
        return DiagnosticSeverity.information;
    }
  }

  static int _mapSeverityToLsp(DiagnosticSeverity severity) {
    switch (severity) {
      case DiagnosticSeverity.error:
        return 1;
      case DiagnosticSeverity.warning:
        return 2;
      case DiagnosticSeverity.information:
        return 3;
      case DiagnosticSeverity.hint:
        return 4;
    }
  }
}

class DiagnosticManager {
  final List<Diagnostic> _diagnostics = [];
  final Buffer buffer;

  DiagnosticManager(this.buffer);

  void setDiagnostics(List<Diagnostic> diagnostics) {
    _diagnostics
      ..clear()
      ..addAll(diagnostics);

    buffer.events.emit(BufferEventType.diagnostic.index);
  }

  void addDiagnostic(Diagnostic diagnostic) {
    _diagnostics.add(diagnostic);

    buffer.events.emit(BufferEventType.diagnostic.index, {
      'diagnostic': diagnostic,
    });
  }

  void removeDiagnostic(Diagnostic diagnostic) {
    _diagnostics.remove(diagnostic);
    buffer.events.emit(BufferEventType.diagnostic.index, {
      'diagnostic': diagnostic,
    });
  }

  List<Diagnostic> diagnosticsForLine(int line) {
    return _diagnostics.where((d) => d.line == line).toList();
  }

  List<Diagnostic> get all => _diagnostics;
}
