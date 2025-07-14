import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:codiaq_editor/src/ui/cq_widgets/theme.dart';

class CQLink extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final bool disabled;

  const CQLink({
    super.key,
    required this.text,
    this.onTap,
    this.disabled = false,
  });

  factory CQLink.dropdown({
    required String text,
    VoidCallback? onTap,
    bool disabled = false,
  }) {
    return CQLink(text: text, onTap: onTap, disabled: disabled);
  }

  @override
  State<CQLink> createState() => _CQLinkState();
}

class _CQLinkState extends State<CQLink> {
  bool _isHovered = false;
  bool _isFocused = false;
  bool _isPressed = false;

  void _handleTap() {
    if (widget.onTap != null && !widget.disabled) {
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CQTheme.of(context);
    bool underline = false;

    Color textColor = theme.primaryColor;
    Color underlineColor = theme.primaryColor;

    if (widget.disabled) {
      textColor = theme.disabledTextColor;
    } else if (_isHovered) {
      underline = true;
    } else if (_isPressed) {
      underlineColor = theme.primaryColor;
    } else if (_isFocused) {
      underlineColor = theme.buttonStyle.focusedBorderColor;
    }

    return FocusableActionDetector(
      onShowFocusHighlight: (value) {
        if (mounted) setState(() => _isFocused = value);
      },
      child: MouseRegion(
        cursor:
            widget.disabled
                ? SystemMouseCursors.forbidden
                : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: _handleTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: RichText(
              text: TextSpan(
                text: widget.text,
                style: TextStyle(
                  color: textColor,
                  decoration: (underline) ? TextDecoration.underline : null,
                  decorationColor: (underline) ? underlineColor : null,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
