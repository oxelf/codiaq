import 'package:codiaq_editor/codiaq_editor.dart';
import 'package:codiaq_editor/src/ui/tabbar.dart';
import 'package:flutter/material.dart';

import '../icons/seti.dart';
import 'tool_bar.dart';

class ProjectIDE extends StatefulWidget {
  final Project project;
  const ProjectIDE({super.key, required this.project});

  @override
  State<ProjectIDE> createState() => _ProjectIDEState();
}

class _ProjectIDEState extends State<ProjectIDE>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  @override
  void initState() {
    tabController = TabController(
      length: widget.project.buffers.length,
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    setState(() {});
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return EditorThemeProvider(
      theme: widget.project.theme,
      child: IconTheme(
        data: IconThemeData(color: widget.project.theme.baseStyle.color),
        child: Column(
          children: [
            ToolBarWidget(project: widget.project),
            Expanded(
              child: ToolWindowWrapper(
                project: widget.project,
                toolWindowManager: widget.project.toolWindowManager,
                theme: widget.project.theme,
                child:
                    (widget.project.buffers.isNotEmpty)
                        ? ValueListenableBuilder(
                          valueListenable: widget.project.currentBuffer,
                          builder: (context, value, child) {
                            var buf = widget.project.buffers[value];
                            return Column(
                              children: [
                                ListenableBuilder(
                                  listenable: widget.project.buffers,
                                  builder: (context, _) {
                                    return TabBarWidget(
                                      tabs: widget.project.buffers.buffers,
                                      onTabClosed: (index) {
                                        widget.project.closeBufferIndex(index);
                                        print("Tab closed: $index");
                                      },
                                      onTabSelected: (index) {
                                        widget.project.currentBuffer.value =
                                            index;
                                      },
                                      activeTabIndex: value,
                                      onTabReordered: (oldIndex, newIndex) {
                                        widget.project.reorderBuffers(
                                          oldIndex,
                                          newIndex,
                                        );
                                        print(
                                          "Tab reordered from $oldIndex to $newIndex",
                                        );
                                      },
                                      //indicatorColor:
                                      //    widget.project.theme.selectionColor,
                                      //tabs:
                                      //    widget.project.buffers.map((buf) {
                                      //      return Padding(
                                      //        padding: const EdgeInsets.symmetric(
                                      //          horizontal: 4.0,
                                      //          vertical: 6,
                                      //        ),
                                      //        child: Row(
                                      //          mainAxisSize: MainAxisSize.min,
                                      //          key: Key(
                                      //            buf.path + buf.id.toString(),
                                      //          ),
                                      //          children: [
                                      //            getSetiIcon(buf.path),
                                      //            Text(
                                      //              buf.path.split('/').last,
                                      //              style: TextStyle(
                                      //                overflow:
                                      //                    TextOverflow.ellipsis,
                                      //                color:
                                      //                    widget
                                      //                        .project
                                      //                        .theme
                                      //                        .baseStyle
                                      //                        .color,
                                      //              ),
                                      //            ),
                                      //          ],
                                      //        ),
                                      //      );
                                      //    }).toList(),
                                    );
                                  },
                                ),
                                Expanded(
                                  child: BufferWidget(
                                    key: Key(buf.path + buf.id.toString()),
                                    buffer: buf,
                                  ),
                                ),
                              ],
                            );
                          },
                        )
                        : Text("no buffers open"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
