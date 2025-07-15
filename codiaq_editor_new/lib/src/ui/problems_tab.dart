import 'package:codiaq_editor/codiaq_editor.dart';
import 'package:codiaq_editor/src/icons/seti.dart';
import 'package:codiaq_editor/src/theme/theme.dart';
import 'package:flutter/material.dart';

import '../buffer/diagnostic.dart';

// Diagnostics definition:

//enum DiagnosticSeverity { error, warning, information, hint }
//
//class Diagnostic {
//  final int line;
//  final int startCol;
//  final int endCol;
//  final String message;
//  final String documentationUrl;
//  final DiagnosticSeverity severity;
//
//  Diagnostic({
//    required this.line,
//    required this.startCol,
//    required this.endCol,
//    required this.message,
//    required this.severity,
//    this.documentationUrl = '',
//  });

class ProblemsTabWidget extends StatelessWidget {
  final Map<String, List<Diagnostic>>? diagnostics;
  final Function(String, Diagnostic)? onDiagnosticClick;
  const ProblemsTabWidget({
    super.key,
    required this.diagnostics,
    this.onDiagnosticClick,
  });

  @override
  Widget build(BuildContext context) {
    final theme = EditorThemeProvider.of(context);
    if (diagnostics == null || diagnostics!.isEmpty) {
      return Center(
        child: Text(
          "No problems found.",
          style: TextStyle(color: theme.baseStyle.color),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children:
          diagnostics!.entries.map((entry) {
            final filePath = entry.key;
            final fileName = filePath.split(RegExp(r'[\\/]+')).last;
            final problems = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // File header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        getSetiIcon(fileName),
                        const SizedBox(width: 8),
                        Text(
                          fileName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            filePath,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${problems.length} ${problems.length == 1 ? "problem" : "problems"}',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // List of diagnostics for this file
                  ...problems.map(
                    (diag) => Padding(
                      padding: const EdgeInsets.only(
                        left: 32,
                        right: 12,
                        top: 4,
                        bottom: 4,
                      ),
                      child: GestureDetector(
                        onDoubleTap: () {
                          if (onDiagnosticClick != null) {
                            onDiagnosticClick!(filePath, diag);
                          }
                        },
                        child: Row(
                          children: [
                            Icon(
                              _iconForSeverity(diag.severity),
                              size: 16,
                              color: _colorForSeverity(diag.severity),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                diag.message,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              ':${diag.line}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  IconData _iconForSeverity(DiagnosticSeverity severity) {
    switch (severity) {
      case DiagnosticSeverity.error:
        return Icons.error;
      case DiagnosticSeverity.warning:
        return Icons.warning;
      case DiagnosticSeverity.information:
        return Icons.info;
      case DiagnosticSeverity.hint:
        return Icons.lightbulb;
    }
  }

  Color _colorForSeverity(DiagnosticSeverity severity) {
    switch (severity) {
      case DiagnosticSeverity.error:
        return Colors.redAccent;
      case DiagnosticSeverity.warning:
        return Colors.orangeAccent;
      case DiagnosticSeverity.information:
        return Colors.blueAccent;
      case DiagnosticSeverity.hint:
        return Colors.lightGreen;
    }
  }
}
