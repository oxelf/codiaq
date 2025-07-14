import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

//const EditorTheme({
//  this.baseStyle = const TextStyle(
//    fontSize: 16,
//    fontFamily: "JetbrainsMono",
//    package: "codiaq_editor",
//    color: Colors.white,
//  ),
//  this.hoverColor = const Color.fromARGB(255, 80, 82, 83),
//  this.gutterRightSize = 40.0,
//  this.popupBackgroundColor,
//  this.backgroundColor = const Color(0xFF1E1E1E),
//  this.secondaryBackgroundColor = const Color.fromARGB(255, 43, 45, 48),
//  this.dividerColor = const Color(0xFF323438),
//  this.cursorColor = const Color(0xFFAEAFAD),
//  this.lineHighlightColor = const Color(0xFF26282D),
//  this.selectionColor = const Color(0xFF264F78),
//  this.diagnosticColors = const DiagnosticColors(),
//  this.maxLineNumber,
//  this.relativeLineNumbers = false,
//  this.showBreakpoints = false,
//  this.showGutter = true,
//  this.tabSize = 2,
//  this.iconTheme = const IconThemeData(color: Colors.white, size: 16),
//  this.diagnosticSeverityColors = const {
//    DiagnosticSeverity.error: Color(0xFFFF0000),
//    DiagnosticSeverity.warning: Color(0xFFFFA500),
//    DiagnosticSeverity.information: Color(0xFF00FFFF),
//    DiagnosticSeverity.hint: Color(0xFF00FF00),
//  },
//  this.vimCursorStyles = const {
//    VimMode.normal: CursorStyle.block,
//    VimMode.insert: CursorStyle.line,
//    VimMode.visual: CursorStyle.block,
//  },
//  this.cursorStyle = CursorStyle.line,
//});

//var theme = cq.EditorTheme(
//  // intellij background color
//  backgroundColor: Color(0xFF1E1F22),
//baseStyle: const TextStyle(
//  color: Colors.white,
//  fontFamily: 'JetBrainsMono',
//  package: "codiaq_editor",
//  fontSize: 20,
//),
//  dividerColor: Color.fromARGB(255, 57, 59, 64),
//  popupBackgroundColor: Color(0xFF2B2D30),
//  showBreakpoints: true,
//  relativeLineNumbers: false,
//  cursorColor: Colors.white70,
//  selectionColor: Colors.blue.withOpacity(0.3),
//);

class CQIconTheme {
  final Color iconColor;
  final Color iconHoverColor;
  final double iconSize;

  const CQIconTheme({
    this.iconColor = const Color(0xFFBBBBBB),
    this.iconHoverColor = const Color(0xFF5EACD0),
    this.iconSize = 16.0,
  });

  CQIconTheme copyWith({
    Color? iconColor,
    double? iconSize,
    Color? iconHoverColor,
  }) {
    return CQIconTheme(
      iconColor: iconColor ?? this.iconColor,
      iconSize: iconSize ?? this.iconSize,
      iconHoverColor: iconHoverColor ?? this.iconHoverColor,
    );
  }
}

class CQThemeData {
  final Color backgroundColor;
  final Color caretColor;
  final Color selectionColor;
  final TextStyle textStyle;
  final CQButtonStyle buttonStyle;
  final CQInputTheme inputTheme;
  final CQIconTheme iconTheme;
  final Color disabledTextColor;
  final Color primaryColor;

  CQThemeData({
    this.primaryColor = const Color.fromARGB(255, 69, 115, 232),
    this.disabledTextColor = const Color.fromARGB(255, 90, 92, 96),
    this.backgroundColor = const Color(0xFF3C3F41),
    this.caretColor = const Color(0xFFBBBBBB),
    this.selectionColor = const Color(0xFFdedede),
    this.textStyle = const TextStyle(color: Color(0xFFFFFFFF)),
    this.buttonStyle = const CQButtonStyle(),
    this.inputTheme = const CQInputTheme(),
    this.iconTheme = const CQIconTheme(),
  });

  CQThemeData copyWith({
    Color? backgroundColor,
    Color? primaryColor,
    Color? caretColor,
    Color? selectionColor,
    Color? disabledTextColor,
    TextStyle? textStyle,
    CQButtonStyle? buttonStyle,
    CQInputTheme? inputTheme,
    CQIconTheme? iconTheme,
  }) {
    return CQThemeData(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      primaryColor: primaryColor ?? this.primaryColor,
      caretColor: caretColor ?? this.caretColor,
      selectionColor: selectionColor ?? this.selectionColor,
      disabledTextColor: disabledTextColor ?? this.disabledTextColor,
      textStyle: textStyle ?? this.textStyle,
      buttonStyle: buttonStyle ?? this.buttonStyle,
      inputTheme: inputTheme ?? this.inputTheme,
      iconTheme: iconTheme ?? this.iconTheme,
    );
  }
}

class CQInputTheme {
  final Color focusedBorderColor;
  final Color hoverBackgroundColor;
  final Color hoverBorderColor;
  final Color disabledBackgroundColor;
  final Color borderColor;

  const CQInputTheme({
    this.focusedBorderColor = const Color.fromARGB(255, 69, 115, 232),
    this.hoverBackgroundColor = const Color(0xFF4C5052),
    this.hoverBorderColor = const Color(0xFF4C5052),
    this.disabledBackgroundColor = const Color(0xFF3c3f41),
    this.borderColor = const Color.fromARGB(255, 79, 81, 86),
  });

  CQInputTheme copyWith({
    Color? focusedBorderColor,
    Color? hoverBackgroundColor,
    Color? hoverBorderColor,
    Color? pressedBackgroundColor,
    Color? pressedBorderColor,
    Color? disabledBackgroundColor,
    Color? borderColor,
  }) {
    return CQInputTheme(
      focusedBorderColor: focusedBorderColor ?? this.focusedBorderColor,
      hoverBackgroundColor: hoverBackgroundColor ?? this.hoverBackgroundColor,
      hoverBorderColor: hoverBorderColor ?? this.hoverBorderColor,
      disabledBackgroundColor:
          disabledBackgroundColor ?? this.disabledBackgroundColor,
      borderColor: borderColor ?? this.borderColor,
    );
  }
}

class CQButtonStyle {
  final Color focusedBorderColor;
  final Color hoverBackgroundColor;
  final Color hoverBorderColor;
  final Color pressedBackgroundColor;
  final Color pressedBorderColor;
  final Color primaryBackgroundColor;

  const CQButtonStyle({
    this.primaryBackgroundColor = const Color.fromARGB(255, 69, 115, 232),
    this.focusedBorderColor = const Color.fromARGB(255, 69, 115, 232),
    this.hoverBackgroundColor = const Color(0xFF4C5052),
    this.hoverBorderColor = const Color(0xFF4C5052),
    this.pressedBackgroundColor = const Color(0xFF5C6164),
    this.pressedBorderColor = const Color.fromARGB(255, 69, 115, 232),
  });

  CQButtonStyle copyWith({
    Color? focusedBorderColor,
    Color? hoverBackgroundColor,
    Color? hoverBorderColor,
    Color? pressedBackgroundColor,
    Color? pressedBorderColor,
    Color? primaryBackgroundColor,
  }) {
    return CQButtonStyle(
      primaryBackgroundColor:
          primaryBackgroundColor ?? this.primaryBackgroundColor,
      focusedBorderColor: focusedBorderColor ?? this.focusedBorderColor,
      hoverBackgroundColor: hoverBackgroundColor ?? this.hoverBackgroundColor,
      hoverBorderColor: hoverBorderColor ?? this.hoverBorderColor,
      pressedBackgroundColor:
          pressedBackgroundColor ?? this.pressedBackgroundColor,
      pressedBorderColor: pressedBorderColor ?? this.pressedBorderColor,
    );
  }
}

class CQTheme extends InheritedWidget {
  final CQThemeData theme;

  const CQTheme({super.key, required this.theme, required super.child});

  static CQThemeData of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<CQTheme>();
    if (provider == null) {
      throw FlutterError('CQTheme not found in context');
    }
    return provider.theme;
  }

  @override
  bool updateShouldNotify(CQTheme oldWidget) => theme != oldWidget.theme;
}
