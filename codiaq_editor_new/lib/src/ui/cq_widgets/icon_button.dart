import 'package:codiaq_editor/codiaq_editor.dart';
import 'package:flutter/material.dart';

class CQIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final double size;
  final Color? color;
  final Color? backgroundColor;
  final Color? hoverColor;

  const CQIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.size = 20.0,
    this.color,
    this.backgroundColor,
    this.hoverColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = EditorThemeProvider.of(context);
    final defaultHoverColor = theme.hoverColor;

    Widget button = Container(
      width: size + 8,
      height: size + 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: backgroundColor ?? Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          hoverColor: hoverColor ?? defaultHoverColor,
          onTap: onPressed,
          child: Center(child: Icon(icon, size: size)),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}
