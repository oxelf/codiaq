import 'package:codiaq_editor/codiaq_editor.dart';
import 'package:codiaq_editor/src/project/project.dart';
import 'package:flutter/material.dart';

import 'tool_bar.dart';

class ProjectIDE extends StatefulWidget {
  final Project project;
  const ProjectIDE({super.key, required this.project});

  @override
  State<ProjectIDE> createState() => _ProjectIDEState();
}

class _ProjectIDEState extends State<ProjectIDE> {
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
                toolWindowManager: widget.project.toolWindowManager,
                theme: widget.project.theme,
                child:
                    (widget.project.buffers.isNotEmpty)
                        ? ValueListenableBuilder(
                          valueListenable: widget.project.currentBuffer,
                          builder: (context, value, child) {
                            var buf = widget.project.buffers[value];
                            return BufferWidget(
                              key: Key(buf.path + buf.id.toString()),
                              buffer: buf,
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
