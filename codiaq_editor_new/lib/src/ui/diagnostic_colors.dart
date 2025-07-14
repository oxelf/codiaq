import 'package:flutter/rendering.dart';

class DiagnosticColors {
  final Color error;
  final Color warning;
  final Color information;
  final Color hint;

  const DiagnosticColors({
    this.error = const Color(0xFFFF0000), // Red for errors
    this.warning = const Color(0xFFFFA500), // Orange for warnings
    this.information = const Color(0xFF0000FF), // Blue for information
    this.hint = const Color(0xFF008000), // Green for hints
  });
}
