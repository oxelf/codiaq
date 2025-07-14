import 'package:codiaq_editor/src/input/vim_adapter.dart';
import 'package:codiaq_editor/src/ui/diagnostic_colors.dart';
import 'package:codiaq_editor/src/window/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../buffer/diagnostic.dart';

class EditorTheme {
  final TextStyle baseStyle;
  final double gutterRightSize;
  final Color backgroundColor;
  final Color hoverColor;
  final Color secondaryBackgroundColor;
  final Color lineHighlightColor;
  final Color cursorColor;
  final Color selectionColor;
  final DiagnosticColors diagnosticColors;
  final Map<VimMode, CursorStyle> vimCursorStyles;
  final CursorStyle cursorStyle;
  final bool relativeLineNumbers;
  final int? maxLineNumber;
  // intellij divider color between gutter and editor
  final Color dividerColor;
  final Color? popupBackgroundColor;
  final bool showBreakpoints;
  final bool showGutter;
  final Map<DiagnosticSeverity, Color> diagnosticSeverityColors;
  final int tabSize;
  final IconThemeData iconTheme;

  const EditorTheme({
    this.baseStyle = const TextStyle(
      fontSize: 16,
      fontFamily: "JetbrainsMono",
      package: "codiaq_editor",
      color: Colors.white,
    ),
    this.hoverColor = const Color.fromARGB(255, 80, 82, 83),
    this.gutterRightSize = 40.0,
    this.popupBackgroundColor,
    this.backgroundColor = const Color(0xFF1E1E1E),
    this.secondaryBackgroundColor = const Color.fromARGB(255, 43, 45, 48),
    this.dividerColor = const Color(0xFF323438),
    this.cursorColor = const Color(0xFFAEAFAD),
    this.lineHighlightColor = const Color(0xFF26282D),
    this.selectionColor = const Color(0xFF264F78),
    this.diagnosticColors = const DiagnosticColors(),
    this.maxLineNumber,
    this.relativeLineNumbers = false,
    this.showBreakpoints = false,
    this.showGutter = true,
    this.tabSize = 2,
    this.iconTheme = const IconThemeData(color: Colors.white, size: 16),
    this.diagnosticSeverityColors = const {
      DiagnosticSeverity.error: Color(0xFFFF0000),
      DiagnosticSeverity.warning: Color(0xFFFFA500),
      DiagnosticSeverity.information: Color(0xFF00FFFF),
      DiagnosticSeverity.hint: Color(0xFF00FF00),
    },
    this.vimCursorStyles = const {
      VimMode.normal: CursorStyle.block,
      VimMode.insert: CursorStyle.line,
      VimMode.visual: CursorStyle.block,
    },
    this.cursorStyle = CursorStyle.line,
  });

  EditorTheme copyWith({
    TextStyle? baseStyle,
    double? gutterRightSize,
    Color? backgroundColor,
    Color? cursorColor,
    Color? selectionColor,
    Color? lineHighlightColor,
    Color? hoverColor,
    DiagnosticColors? diagnosticColors,
    Map<VimMode, CursorStyle>? vimCursorStyles,
    CursorStyle? cursorStyle,
    bool? relativeLineNumbers,
    int? maxLineNumber,
    Color? dividerColor,
    Color? popupBackgroundColor,
    bool? showBreakpoints,
    Map<DiagnosticSeverity, Color>? diagnosticSeverityColors,
    bool? showGutter,
    int? tabSize,
  }) {
    return EditorTheme(
      hoverColor: hoverColor ?? this.hoverColor,
      baseStyle: baseStyle ?? this.baseStyle,
      gutterRightSize: gutterRightSize ?? this.gutterRightSize,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      cursorColor: cursorColor ?? this.cursorColor,
      selectionColor: selectionColor ?? this.selectionColor,
      diagnosticColors: diagnosticColors ?? this.diagnosticColors,
      vimCursorStyles: vimCursorStyles ?? this.vimCursorStyles,
      cursorStyle: cursorStyle ?? this.cursorStyle,
      relativeLineNumbers: relativeLineNumbers ?? this.relativeLineNumbers,
      maxLineNumber: maxLineNumber ?? this.maxLineNumber,
      dividerColor: dividerColor ?? this.dividerColor,
      popupBackgroundColor: popupBackgroundColor ?? this.popupBackgroundColor,
      showBreakpoints: showBreakpoints ?? this.showBreakpoints,
      diagnosticSeverityColors:
          diagnosticSeverityColors ?? this.diagnosticSeverityColors,
      lineHighlightColor: lineHighlightColor ?? this.lineHighlightColor,
      showGutter: showGutter ?? this.showGutter,
      tabSize: tabSize ?? this.tabSize,
    );
  }

  @override
  bool operator ==(Object other) {
    return super.hashCode == other.hashCode;
  }

  @override
  int get hashCode =>
      baseStyle.hashCode ^
      gutterRightSize.hashCode ^
      backgroundColor.hashCode ^
      cursorColor.hashCode ^
      selectionColor.hashCode;
}
