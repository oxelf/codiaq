import 'package:codiaq_editor/codiaq_editor.dart';
import 'package:codiaq_editor/src/buffer/completion_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:codiaq_editor/codiaq_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../buffer/popup.dart';

class CompletionPopup extends StatefulWidget {
  final Buffer buffer;
  final List<Completion> completions;

  const CompletionPopup({
    super.key,
    required this.buffer,
    required this.completions,
  });

  @override
  State<CompletionPopup> createState() => CompletionPopupState();
}

class CompletionPopupState extends State<CompletionPopup>
    implements BasePopupController {
  late Popup self;

  int selectedIndex = 0;
  int? hoveredIndex;

  final ScrollController scrollController = ScrollController();
  final List<GlobalKey> itemKeys = [];

  @override
  void initState() {
    super.initState();
    itemKeys.addAll(
      List.generate(widget.completions.length, (_) => GlobalKey()),
    );
  }

  @override
  void onClose() {}

  bool onKeyEvent(KeyEvent event) {
    final length = widget.completions.length;

    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          selectedIndex = (selectedIndex + 1) % length;
        });
        _scrollToSelected();
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          selectedIndex = (selectedIndex - 1 + length) % length;
        });
        _scrollToSelected();
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.enter &&
          selectedIndex >= 0) {
        final item = widget.completions[selectedIndex];
        widget.buffer.completions.applyCompletion(item);
        widget.buffer.popupManager.removePopupByType("completion");
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        widget.buffer.popupManager.removePopupByType("completion");
        return true;
      }
    }
    return false;
  }

  void _scrollToSelected() {
    if (selectedIndex < 0 || selectedIndex >= itemKeys.length) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectedContext = itemKeys[selectedIndex].currentContext;
      if (selectedContext == null) return;

      final scrollBox = scrollController.position;
      final itemBox = selectedContext.findRenderObject() as RenderBox;

      final itemPosition = itemBox.localToGlobal(
        Offset.zero,
        ancestor: context.findRenderObject(),
      );
      final viewportTop = scrollBox.pixels;
      final viewportBottom = scrollBox.pixels + scrollBox.viewportDimension;

      final itemTop = itemPosition.dy + scrollBox.pixels;
      final itemBottom = itemTop + itemBox.size.height;

      if (itemTop < viewportTop) {
        scrollController.animateTo(
          itemTop,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
      } else if (itemBottom > viewportBottom) {
        scrollController.animateTo(
          itemBottom - scrollBox.viewportDimension,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = EditorThemeProvider.of(context);
    final completions = widget.completions;

    return IntrinsicWidth(
      child: SingleChildScrollView(
        controller: scrollController,
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: List.generate(completions.length, (index) {
            final completion = completions[index];
            final isSelected = index == selectedIndex;
            final isHovered = index == hoveredIndex;

            return MouseRegion(
              onEnter: (_) {
                setState(() {
                  hoveredIndex = index;
                });
              },
              onExit: (_) {
                if (hoveredIndex == index) {
                  setState(() {
                    hoveredIndex = null;
                  });
                }
              },
              child: GestureDetector(
                onTap: () {
                  widget.buffer.completions.applyCompletion(completion);
                  widget.buffer.popupManager.removePopupByType("completion");
                },
                child: Container(
                  key: itemKeys[index],
                  color:
                      isSelected
                          ? theme.selectionColor
                          : (isHovered
                              ? theme.selectionColor.withOpacity(0.6)
                              : Colors.transparent),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.code, size: 16, color: theme.baseStyle.color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          completion.label,
                          overflow: TextOverflow.ellipsis,
                          style: theme.baseStyle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
