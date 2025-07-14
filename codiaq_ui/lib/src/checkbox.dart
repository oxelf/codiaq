import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'theme.dart';

enum CheckboxState { checked, unchecked, indeterminate, disabled }

class CQCheckbox extends StatefulWidget {
  final CheckboxState state;
  final Function(CheckboxState state)? onTap;

  const CQCheckbox({
    super.key,
    this.state = CheckboxState.unchecked,
    this.onTap,
  });

  @override
  State<CQCheckbox> createState() => _CQCheckboxState();
}

class _CQCheckboxState extends State<CQCheckbox> {
  bool _isHovered = false;
  bool _isFocused = false;
  bool _isPressed = false;

  void _handleTap() {
    if (widget.onTap != null && widget.state != CheckboxState.disabled) {
      widget.onTap!(widget.state); // Pass current state to user
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = CQTheme.of(context);
    final isInteractive =
        widget.state != CheckboxState.disabled && widget.onTap != null;

    Color backgroundColor = theme.backgroundColor;
    Color borderColor = theme.buttonStyle.hoverBorderColor;
    Color iconColor = theme.iconTheme.iconColor;

    if (widget.state == CheckboxState.checked) {
      backgroundColor = theme.buttonStyle.primaryBackgroundColor;
    } else if (widget.state == CheckboxState.indeterminate) {
      backgroundColor = theme.buttonStyle.primaryBackgroundColor;
    } else if (widget.state == CheckboxState.disabled) {
      backgroundColor = theme.backgroundColor;
      iconColor = theme.disabledTextColor;
    }

    if (_isHovered && isInteractive) {
      borderColor = theme.buttonStyle.hoverBorderColor;
    }
    if (_isPressed && isInteractive) {
      backgroundColor = theme.buttonStyle.pressedBackgroundColor;
      borderColor = theme.buttonStyle.pressedBorderColor;
    }
    if (_isFocused && isInteractive) {
      borderColor = theme.buttonStyle.focusedBorderColor;
    }

    final icon = widget.state == CheckboxState.checked
        ? Icon(Icons.check, color: iconColor, size: 16)
        : widget.state == CheckboxState.indeterminate
        ? Icon(Icons.remove, color: iconColor, size: 16)
        : null;

    return FocusableActionDetector(
      onShowFocusHighlight: (value) {
        if (mounted) setState(() => _isFocused = value);
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: _handleTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Center(child: icon),
          ),
        ),
      ),
    );
  }
}
