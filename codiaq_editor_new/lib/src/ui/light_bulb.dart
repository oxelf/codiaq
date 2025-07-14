import 'package:codiaq_editor/src/window/cursor.dart';
import 'package:flutter/material.dart';

import '../buffer/buffer.dart';
import '../buffer/code_action.dart';
import '../buffer/popup.dart';
import 'code_actions_list.dart';

class LightBulbWidget extends StatefulWidget {
  final Buffer buffer;
  final List<CodeAction> codeActions;
  final CursorPosition position;
  const LightBulbWidget({
    super.key,
    required this.buffer,
    required this.codeActions,
    required this.position,
  });

  @override
  State<LightBulbWidget> createState() => _LightBulbWidgetState();
}

class _LightBulbWidgetState extends State<LightBulbWidget> {
  bool isHovered = false;
  @override
  Widget build(BuildContext context) {
    var theme = widget.buffer.theme;
    return GestureDetector(
      onTap: () {
        if (widget.buffer.popupManager.popups.any(
          (p) => p.type == "codeActions",
        )) {
          widget.buffer.popupManager.removePopupByType("codeActions");
          return;
        }
        final stateKey = GlobalKey<CodeActionsPopupState>();
        var popup = Popup(
          zIndex: 3,
          type: "codeActions",
          disallowOtherPopups: true,
          content: CodeActionsPopup(
            key: stateKey,
            buffer: widget.buffer,
            codeActions: widget.codeActions,
          ),
          position: widget.position,
          key: stateKey,
          closeOnExit: false,
          closeOnTapOutside: true,
        );
        widget.buffer.popupManager.removePopupByType("hover");
        widget.buffer.popupManager.addPopup(popup);
      },
      child: Icon(
        Icons.lightbulb,
        color: Colors.yellow,
        size: theme.baseStyle.fontSize ?? 16,
        semanticLabel: 'Light Bulb',
      ),
    );
  }
}
