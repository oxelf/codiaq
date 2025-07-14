import 'package:codiaq_editor/codiaq_editor.dart';
import 'package:codiaq_editor/src/buffer/code_action.dart';
import 'package:codiaq_editor/src/ui/markdown_renderer.dart';
import 'package:flutter/material.dart';

import '../buffer/popup.dart';
import '../window/cursor.dart';
import 'code_actions_list.dart';

class HoverPopup extends StatefulWidget {
  final Diagnostic? diagnostic;
  final String? hoverInfo;
  final Buffer buffer;
  final List<CodeAction> codeActions;
  final CursorPosition hoverPosition;
  const HoverPopup({
    super.key,
    required this.buffer,
    required this.hoverPosition,
    this.codeActions = const [],
    this.diagnostic,
    this.hoverInfo,
  });

  @override
  State<HoverPopup> createState() => _HoverPopupState();
}

class _HoverPopupState extends State<HoverPopup> {
  @override
  Widget build(BuildContext context) {
    var theme = EditorThemeProvider.of(context);
    var size = MediaQuery.sizeOf(context);
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          if ((widget.diagnostic?.message ?? "").isNotEmpty)
            Container(
              color: theme.lineHighlightColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Text(
                        widget.diagnostic?.message ?? "",
                        style: theme.baseStyle,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (widget.codeActions.isNotEmpty)
            Container(
              color: theme.lineHighlightColor,
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      if (widget.codeActions.isNotEmpty) {
                        widget.buffer.lsp.executeCodeAction(
                          widget.codeActions[0],
                        );
                      }
                      widget.buffer.popupManager.removePopupByType("hover");
                    },
                    child: Text(
                      widget.codeActions[0].title,
                      style: theme.baseStyle.copyWith(color: Colors.blue),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
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
                        position: widget.hoverPosition, // Adjust as needed
                        key: stateKey,
                        closeOnExit: false,
                        closeOnTapOutside: true,
                      );
                      widget.buffer.popupManager.removePopupByType("hover");
                      widget.buffer.popupManager.addPopup(popup);
                    },
                    child: Text(
                      "More actions...",
                      style: theme.baseStyle.copyWith(color: Colors.blue),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(8),
            child: MarkdownRenderer(
              markdown: widget.hoverInfo ?? "",
              buffer: widget.buffer,
            ),
          ),
        ],
      ),
    );
  }
}
