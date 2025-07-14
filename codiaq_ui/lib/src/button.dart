import 'theme.dart';
import 'package:flutter/widgets.dart';

class CQButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool disabled;
  final CQButtonStyle? style;
  final bool secondary;

  const CQButton({
    super.key,
    required this.label,
    this.onPressed,
    this.disabled = false,
    this.style,
    this.secondary = false,
  });

  factory CQButton.secondary({
    required String label,
    VoidCallback? onPressed,
    bool disabled = false,
    CQButtonStyle? style,
  }) {
    return CQButton(
      label: label,
      onPressed: onPressed,
      disabled: disabled,
      secondary: true,
      style: style,
    );
  }

  @override
  State<CQButton> createState() => _CQButtonState();
}

class _CQButtonState extends State<CQButton> {
  bool _isHovered = false;
  bool _isPressed = false;
  bool _hasFocus = false;

  @override
  Widget build(BuildContext context) {
    final theme = CQTheme.of(context);
    final effectiveStyle = widget.style ?? theme.buttonStyle;
    //final isInteractive = widget.onPressed != null && !widget.disabled;

    Color backgroundColor = theme.buttonStyle.primaryBackgroundColor;
    if (widget.secondary || widget.disabled) {
      backgroundColor = theme.backgroundColor;
    }
    Color borderColor = _hasFocus
        ? effectiveStyle.focusedBorderColor
        : widget.secondary
        ? effectiveStyle.hoverBorderColor
        : Color(0x00000000);
    Color? textColor = theme.textStyle.color;
    if (widget.disabled) {
      textColor = theme.disabledTextColor;
    }

    return FocusableActionDetector(
      enabled: !widget.disabled,
      onShowFocusHighlight: (value) {
        setState(() {
          _hasFocus = value;
        });
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.disabled ? null : widget.onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Text(
              widget.label,
              style: TextStyle(color: textColor, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }
}
