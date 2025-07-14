import 'package:codiaq_editor/codiaq_editor.dart';
import 'package:flutter/material.dart';

abstract class CQPopupMenuItem {
  Widget child;

  CQPopupMenuItem({required this.child});
}

class CQPopupMenuDivider extends CQPopupMenuItem {
  CQPopupMenuDivider()
    : super(
        child: Builder(
          builder: (context) {
            var theme = EditorThemeProvider.of(context);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(height: 2, color: theme.dividerColor),
            );
          },
        ),
      );
}

class CQPopupMenuItemSimple extends CQPopupMenuItem {
  final String label;
  final Widget? icon;
  final KeyboardShortcut? shortcut;
  final Function()? onPressed;

  CQPopupMenuItemSimple({
    required this.label,
    this.icon,
    this.shortcut,
    this.onPressed,
  }) : super(
         child: Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             Row(
               mainAxisAlignment: MainAxisAlignment.start,
               children: [
                 SizedBox(
                   width: 24,
                   child: (icon != null) ? icon : const SizedBox(),
                 ),
                 const SizedBox(width: 8),
                 Text(label),
                 const SizedBox(width: 8),
               ],
             ),
             Row(
               children: [
                 if (shortcut != null) const Spacer(),
                 if (shortcut != null) Text(shortcut.toString()),
               ],
             ),
           ],
         ),
       );
}

void showPopupMenu(
  BuildContext context,
  Offset position,
  List<CQPopupMenuItem> items, {
  Color? backgroundColor,
}) {
  final overlay = Overlay.of(context);
  final theme = EditorThemeProvider.of(context);

  final popupMenu = CQPopupMenu(items: items);

  late OverlayEntry entry;
  removeEntry() {
    entry.remove();
  }

  ;
  entry = OverlayEntry(
    builder:
        (context) => Positioned(
          left: position.dx,
          top: position.dy,
          child: TapRegion(
            onTapOutside: (event) {
              removeEntry();
            },
            child: Material(
              textStyle: TextStyle(color: theme.baseStyle.color),
              child: IconTheme(
                data: theme.iconTheme,
                child: EditorThemeProvider(theme: theme, child: popupMenu),
              ),
            ),
          ),
        ),
  );

  overlay.insert(entry);
}

class CQPopupMenu extends StatefulWidget {
  final List<CQPopupMenuItem> items;
  const CQPopupMenu({super.key, required this.items});

  @override
  State<CQPopupMenu> createState() => _CQPopupMenuState();
}

class _CQPopupMenuState extends State<CQPopupMenu> {
  int hoverIndex = -1;
  @override
  Widget build(BuildContext context) {
    var theme = EditorThemeProvider.of(context);
    return IntrinsicWidth(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.secondaryBackgroundColor,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          textStyle: theme.baseStyle,
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                widget.items.map((item) {
                  return MouseRegion(
                    onHover: (event) {
                      if (item is CQPopupMenuDivider) return;
                      setState(() {
                        hoverIndex = widget.items.indexOf(item);
                      });
                    },
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color:
                            hoverIndex == widget.items.indexOf(item)
                                ? theme.selectionColor
                                : Colors.transparent,
                      ),
                      child: item.child,
                    ),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }
}
