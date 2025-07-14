import 'package:codiaq_editor/src/buffer/popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../codiaq_editor.dart';
import '../buffer/code_action.dart';

class CodeActionsPopup extends StatefulWidget {
  final Buffer buffer;
  final List<CodeAction> codeActions;

  const CodeActionsPopup({
    super.key,
    required this.buffer,
    this.codeActions = const [],
  });

  @override
  State<CodeActionsPopup> createState() => CodeActionsPopupState();
}

class CodeActionsPopupState extends State<CodeActionsPopup>
    implements BasePopupController {
  int hoveredIndex = 0;

  @override
  late Popup self;

  @override
  void onClose() {}

  @override
  bool onKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        _closeAllPopups();
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          hoveredIndex = (hoveredIndex + 1) % widget.codeActions.length;
        });
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          hoveredIndex =
              (hoveredIndex - 1 + widget.codeActions.length) %
              widget.codeActions.length;
        });
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        _executeCodeAction(hoveredIndex);
        return true;
      }
    }
    return false;
  }

  void _executeCodeAction(int index) async {
    _closeAllPopups();
    await widget.buffer.lsp.executeCodeAction(widget.codeActions[index]);
    debugPrint('Executed code action: ${widget.codeActions[index].title}');
  }

  void _closeAllPopups() {
    widget.buffer.popupManager.removePopupByType("codeActions");
  }

  @override
  Widget build(BuildContext context) {
    var theme = EditorThemeProvider.of(context);
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(widget.codeActions.length, (i) {
            final isHovered = i == hoveredIndex;
            return MouseRegion(
              onEnter: (_) => setState(() => hoveredIndex = i),
              child: GestureDetector(
                onTap: () => _executeCodeAction(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isHovered ? theme.selectionColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color:
                            isHovered
                                ? theme.selectionColor.withOpacity(0.6)
                                : Colors.transparent,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.codeActions[i].title,
                          style: theme.baseStyle.copyWith(
                            fontWeight:
                                isHovered ? FontWeight.w600 : FontWeight.normal,
                          ),
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
