import 'package:codiaq_editor/codiaq_editor.dart';
import 'package:codiaq_editor/src/tool_window/tool_window_manager.dart';
import 'package:codiaq_editor/src/tool_window/tool_window_titlebar.dart';
import 'package:flutter/material.dart';
import 'package:codiaq_editor/codiaq_editor.dart';
import 'package:codiaq_editor/src/tool_window/tool_window_manager.dart';
import 'package:codiaq_editor/src/tool_window/tool_window_titlebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'tool_window.dart';

class ToolWindowWrapper extends StatefulWidget {
  final ToolWindowManager toolWindowManager;
  final Widget child;
  final EditorTheme theme;
  final Project project;

  const ToolWindowWrapper({
    super.key,
    required this.toolWindowManager,
    required this.child,
    required this.theme,
    required this.project,
  });

  @override
  State<ToolWindowWrapper> createState() => _ToolWindowWrapperState();
}

class _ToolWindowWrapperState extends State<ToolWindowWrapper> {
  List<double> sideSpacing = [250, 0, 200, 200]; // left, top, right, bottom

  @override
  void initState() {
    widget.toolWindowManager.addListener(() {
      if (mounted) setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.theme.backgroundColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          var bottomLeftWindows = widget.toolWindowManager.getWindowsAtVisible(
            Anchor.bottomLeft,
          );
          var bottomRightWindows = widget.toolWindowManager.getWindowsAtVisible(
            Anchor.bottomRight,
          );
          var bottomHeight =
              (bottomLeftWindows.isNotEmpty || bottomRightWindows.isNotEmpty)
                  ? sideSpacing[3]
                  : 0.0;

          var leftTopWindows = widget.toolWindowManager.getWindowsAtVisible(
            Anchor.left,
          );
          var leftWidth = leftTopWindows.isNotEmpty ? sideSpacing[0] : 0.0;

          var rightTopWindows = widget.toolWindowManager.getWindowsAtVisible(
            Anchor.right,
          );
          var rightWidth = rightTopWindows.isNotEmpty ? sideSpacing[2] : 0.0;

          return Row(
            children: [
              // Left vertical toolbar
              Container(
                width: 40,
                height: constraints.maxHeight,
                decoration: BoxDecoration(
                  color: widget.theme.secondaryBackgroundColor,
                  border: Border(
                    right: BorderSide(
                      color: widget.theme.backgroundColor,
                      width: 3,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left tool icons
                    Column(
                      children: [
                        ...widget.toolWindowManager
                            .getWindowsAt(Anchor.left)
                            .map((w) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  radius: 30,
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () {
                                    final id = widget.toolWindowManager.getId(
                                      w,
                                    );
                                    widget.toolWindowManager.toggleVisibility(
                                      id,
                                    );
                                  },
                                  child: IconTheme(
                                    data: widget.theme.iconTheme,
                                    child: SizedBox(child: w.icon),
                                  ),
                                ),
                              );
                            }),
                      ],
                    ),

                    // Bottom left tool icons
                    Column(
                      children: [
                        ...widget.toolWindowManager
                            .getWindowsAt(Anchor.bottomLeft)
                            .map((w) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  radius: 30,
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () {
                                    final id = widget.toolWindowManager.getId(
                                      w,
                                    );
                                    widget.toolWindowManager.toggleVisibility(
                                      id,
                                    );
                                  },
                                  child: IconTheme(
                                    data: widget.theme.iconTheme,
                                    child: SizedBox(child: w.icon),
                                  ),
                                ),
                              );
                            }),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Column(
                  children: [
                    // Top section (main area and vertical side panels)
                    Expanded(
                      child: Row(
                        children: [
                          // Left panel
                          if (leftWidth > 0)
                            SizedBox(
                              width: leftWidth,
                              child: Stack(
                                children: [
                                  Column(
                                    children: [
                                      ...leftTopWindows.map((w) {
                                        return ToolWindowTitlebar(
                                          manager: widget.toolWindowManager,
                                          toolWindow: w,
                                          theme: widget.theme,
                                        );
                                      }).toList(),
                                    ],
                                  ),

                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      width: 2,
                                      color: widget.theme.backgroundColor,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.resizeColumn,
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onHorizontalDragUpdate: (details) {
                                          setState(() {
                                            sideSpacing[0] += details.delta.dx;
                                            sideSpacing[0] = sideSpacing[0]
                                                .clamp(100.0, 600.0);
                                          });
                                        },
                                        child: Container(width: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Left drag handle

                          // Main content area
                          Expanded(child: widget.child),

                          // Right panel
                          if (rightWidth > 0)
                            SizedBox(
                              width: rightWidth,
                              child: Stack(
                                children: [
                                  Column(
                                    children: [
                                      ...rightTopWindows.map(
                                        (w) => ToolWindowTitlebar(
                                          manager: widget.toolWindowManager,
                                          toolWindow: w,
                                          theme: widget.theme,
                                        ),
                                      ),
                                    ],
                                  ),

                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      width: 2,
                                      color: widget.theme.backgroundColor,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.resizeColumn,
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onHorizontalDragUpdate: (details) {
                                          setState(() {
                                            sideSpacing[2] -= details.delta.dx;
                                            sideSpacing[2] = sideSpacing[2]
                                                .clamp(100.0, 600.0);
                                          });
                                        },
                                        child: Container(width: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Bottom drag handle

                    // Bottom tool windows
                    if (bottomHeight > 0)
                      SizedBox(
                        height: bottomHeight,
                        child: Stack(
                          children: [
                            Row(
                              children: [
                                ...bottomLeftWindows.map((w) {
                                  return ToolWindowTitlebar(
                                    manager: widget.toolWindowManager,
                                    toolWindow: w,
                                    theme: widget.theme,
                                  );
                                }),
                                ...bottomRightWindows.map(
                                  (w) => ToolWindowTitlebar(
                                    manager: widget.toolWindowManager,
                                    toolWindow: w,
                                    theme: widget.theme,
                                  ),
                                ),
                              ],
                            ),

                            Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                height: 2,
                                color: widget.theme.backgroundColor,
                              ),
                            ),
                            Align(
                              alignment: Alignment.topCenter,
                              child: MouseRegion(
                                cursor: SystemMouseCursors.resizeRow,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onVerticalDragUpdate: (details) {
                                    setState(() {
                                      sideSpacing[3] -= details.delta.dy;
                                      sideSpacing[3] = sideSpacing[3].clamp(
                                        100.0,
                                        400.0,
                                      );
                                    });
                                  },
                                  child: Container(height: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Right vertical toolbar
              Container(
                width: 40,
                height: constraints.maxHeight,
                decoration: BoxDecoration(
                  color: widget.theme.secondaryBackgroundColor,
                  border: Border(
                    left: BorderSide(
                      color: widget.theme.backgroundColor,
                      width: 3,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left tool icons
                    Column(
                      children: [
                        ...widget.toolWindowManager
                            .getWindowsAt(Anchor.right)
                            .map((w) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  radius: 30,
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () {
                                    final id = widget.toolWindowManager.getId(
                                      w,
                                    );
                                    widget.toolWindowManager.toggleVisibility(
                                      id,
                                    );
                                  },
                                  child: IconTheme(
                                    data: widget.theme.iconTheme,
                                    child: SizedBox(child: w.icon),
                                  ),
                                ),
                              );
                            }),
                      ],
                    ),

                    // Bottom left tool icons
                    Column(
                      children: [
                        ...widget.toolWindowManager
                            .getWindowsAt(Anchor.bottomRight)
                            .map((w) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  radius: 30,
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () {
                                    final id = widget.toolWindowManager.getId(
                                      w,
                                    );
                                    widget.toolWindowManager.toggleVisibility(
                                      id,
                                    );
                                  },
                                  child: IconTheme(
                                    data: widget.theme.iconTheme,
                                    child: SizedBox(child: w.icon),
                                  ),
                                ),
                              );
                            }),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
