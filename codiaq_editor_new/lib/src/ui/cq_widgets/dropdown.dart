import 'package:codiaq_editor/codiaq_editor.dart';
import 'package:flutter/material.dart';

class CQDropdownItem {
  final String text;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isSelected;

  CQDropdownItem({
    required this.text,
    this.icon,
    this.onTap,
    this.isSelected = false,
  });
}

class CQCustomDropdown extends StatelessWidget {
  final List<CQDropdownItem> items;
  final Color? backgroundColor;
  final Color? hoverColor;
  final double width;
  final double itemHeight;

  const CQCustomDropdown({
    super.key,
    required this.items,
    this.backgroundColor,
    this.hoverColor,
    this.width = 200.0,
    this.itemHeight = 28.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = EditorThemeProvider.of(context);
    final defaultBackgroundColor = backgroundColor ?? theme.backgroundColor;
    final defaultHoverColor = hoverColor ?? theme.hoverColor.withOpacity(0.3);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: defaultBackgroundColor,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return InkWell(
              onTap: item.onTap,
              hoverColor: defaultHoverColor,
              child: Container(
                height: itemHeight,
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                color:
                    item.isSelected
                        ? theme.selectionColor.withOpacity(0.2)
                        : Colors.transparent,
                child: Row(
                  children: [
                    if (item.icon != null)
                      Icon(item.icon, size: 16, color: theme.baseStyle.color),
                    if (item.icon != null) const SizedBox(width: 8),
                    Text(
                      item.text,
                      style: TextStyle(
                        color: theme.baseStyle.color,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

void showCQCustomDropdown({
  required BuildContext context,
  required Offset position,
  required List<CQDropdownItem> items,
  Color? backgroundColor,
  Color? hoverColor,
  double width = 200.0,
  double itemHeight = 28.0,
}) {
  final overlay = Overlay.of(context);
  final theme = EditorThemeProvider.of(context);

  final renderBox = context.findRenderObject() as RenderBox?;
  if (renderBox == null) return;

  var overlayEntry;
  overlayEntry = OverlayEntry(
    builder:
        (context) => Positioned(
          left: position.dx,
          top: position.dy,
          child: EditorThemeProvider(
            theme: theme,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              child: CQCustomDropdown(
                items: items,
                backgroundColor: backgroundColor,
                hoverColor: hoverColor,
                width: width,
                itemHeight: itemHeight,
              ),
            ),
          ),
        ),
  );

  overlay.insert(overlayEntry);

  // Remove overlay when clicked outside
  Future.delayed(const Duration(milliseconds: 100), () {
    final gestureDetector = GestureDetector(
      onTap: () {
        overlayEntry.remove();
      },
      child: Container(color: Colors.transparent),
    );
    overlay.insert(OverlayEntry(builder: (context) => gestureDetector));
  });
}
