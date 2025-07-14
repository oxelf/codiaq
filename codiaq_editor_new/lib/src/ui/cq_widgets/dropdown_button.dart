import 'package:codiaq_editor/codiaq_editor.dart';
import 'package:flutter/material.dart';

import 'dropdown.dart';

class CQDropdownButton<T> extends StatelessWidget {
  final T? value;
  final List<CQDropdownItem> items;
  final ValueChanged<T?>? onChanged;
  final String? hint;
  final String? tooltip;
  final double size;
  final Color? color;
  final Color? backgroundColor;
  final Color? hoverColor;
  final IconData dropdownIcon;
  final bool showTimestamp;

  const CQDropdownButton({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.tooltip,
    this.size = 20.0,
    this.color,
    this.backgroundColor,
    this.hoverColor,
    this.dropdownIcon = Icons.arrow_drop_down,
    this.showTimestamp = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = EditorThemeProvider.of(context);
    final defaultHoverColor = theme.hoverColor;
    final defaultIconColor = theme.baseStyle.color;
    final defaultBackgroundColor = backgroundColor ?? Colors.transparent;

    Widget button = Container(
      height: size + 8,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: defaultBackgroundColor,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          hoverColor: hoverColor ?? defaultHoverColor,
          onTap: () {
            if (onChanged != null) {
              final renderBox = context.findRenderObject() as RenderBox?;
              if (renderBox != null) {
                final offset =
                    renderBox.localToGlobal(Offset.zero) +
                    Offset(0, renderBox.size.height);
                showCQCustomDropdown(
                  context: context,
                  position: offset,
                  items: items,
                  backgroundColor: theme.backgroundColor,
                  hoverColor: theme.hoverColor.withOpacity(0.3),
                );
              }
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (value != null)
                Text(
                  items
                      .firstWhere((item) => item.text == value.toString())
                      .text,
                  style: TextStyle(
                    color: color ?? defaultIconColor,
                    fontSize: size * 0.7,
                  ),
                )
              else
                Text(
                  hint ?? 'Select',
                  style: TextStyle(
                    color: (color ?? defaultIconColor)!.withOpacity(0.5),
                    fontSize: size * 0.7,
                  ),
                ),
              const SizedBox(width: 4),
              Icon(
                dropdownIcon,
                size: size,
                color:
                    onChanged != null
                        ? (color ?? defaultIconColor)
                        : (color ?? defaultIconColor)!.withOpacity(0.5),
              ),
              if (showTimestamp)
                Text(
                  '10:18 PM CEST, Jul 11, 2025',
                  style: TextStyle(
                    color: (color ?? defaultIconColor)!.withOpacity(0.5),
                    fontSize: size * 0.5,
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}
