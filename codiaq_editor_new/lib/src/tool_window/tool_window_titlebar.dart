import 'package:codiaq_editor/codiaq_editor.dart';
import 'package:flutter/material.dart';

class ToolWindowTitlebar extends StatelessWidget {
  final ToolWindowManager manager;
  final ToolWindow toolWindow;
  final EditorTheme theme;
  const ToolWindowTitlebar({
    super.key,
    required this.manager,
    required this.toolWindow,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 30,
            color: theme.secondaryBackgroundColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: Text(
                        toolWindow.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.baseStyle.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (toolWindow.titleBar != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: toolWindow.titleBar!,
                      ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        String id = manager.getId(toolWindow);
                        manager.toggleVisibility(id);
                        // Handle drag to move the tool window
                      },
                    ),

                    //IconButton(
                    //  padding: EdgeInsets.zero,
                    //  icon: Icon(Icons.remove),
                    //  onPressed: () {
                    //    String id = manager.getId(toolWindow);
                    //    manager.toggleVisibility(id);
                    //    // Handle drag to move the tool window
                    //  },
                    //),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: theme.secondaryBackgroundColor,
              child: toolWindow.content,
            ),
          ),
        ],
      ),
    );
  }
}
