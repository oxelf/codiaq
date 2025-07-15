import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:codiaq_app/data/recent_projects.dart';
import 'package:codiaq_app/main.dart';
import 'package:codiaq_editor/codiaq_editor.dart';
import 'package:codiaq_ui/codiaq_ui.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? filter;
  @override
  Widget build(BuildContext context) {
    var theme = EditorThemeProvider.of(context);
    var cqTheme = CQTheme.of(context);
    var recents = getRecentProjects();
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: Column(
        children: [
          Container(
            height: 30,
            decoration: BoxDecoration(
              color: theme.secondaryBackgroundColor,
              border: Border(
                bottom: BorderSide(color: theme.dividerColor, width: 1),
              ),
            ),
            child: MoveWindow(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Welcome to Codiaq!",
                    style: TextStyle(color: theme.baseStyle.color),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 400, minWidth: 100),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InputField(
                        onChanged: (value) {
                          setState(() {
                            filter = value.isEmpty ? null : value;
                          });
                        },
                        prefixIcon: Icon(
                          Icons.search,
                          color: theme.iconTheme.color,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    spacing: 8,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CQButton.secondary(label: "New Project"),
                      CQButton.secondary(
                        label: "Open",
                        onPressed: () {
                          pickProject();
                        },
                      ),
                      CQButton.secondary(label: "Get from VCS"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(color: theme.dividerColor, height: 1.5),
          ),
          SizedBox(height: 16),
          FutureBuilder<List<RecentProject>>(
            future: recents,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error loading recent projects"));
              } else if (snapshot.data!.isEmpty) {
                return Center(child: Text("No recent projects found"));
              } else {
                return _buildRecentProjects(cqTheme, snapshot.data!);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentProjects(
    CQThemeData theme,
    List<RecentProject> inputProjects,
  ) {
    var projects = inputProjects.where((p) {
      if (filter == null || filter!.isEmpty) return true;
      return p.name.toLowerCase().contains(filter!.toLowerCase()) ||
          p.rootPath.toLowerCase().contains(filter!.toLowerCase());
    }).toList();
    return Expanded(
      child: ListView.builder(
        itemCount: projects.length,
        itemBuilder: (context, index) {
          var project = projects[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListTile(
              focusColor: theme.inputTheme.focusedBorderColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              minTileHeight: 20,
              hoverColor: theme.inputTheme.focusedBorderColor,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              minVerticalPadding: 0,
              title: Text(
                project.name,
                style: TextStyle(color: theme.textStyle.color, fontSize: 14),
              ),
              subtitle: Text(
                project.rootPath,
                style: TextStyle(color: theme.textStyle.color, fontSize: 12),
              ),
              onTap: () {
                appWindow.size = editorSize;
                context.go(
                  "/project?path=${project.rootPath}",
                  extra: project.rootPath,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> pickProject() async {
    await FilePicker.platform
        .getDirectoryPath()
        .then((result) {
          if (result == null) {
            print("No project selected");
            return;
          }
          addToRecentProjects(
            RecentProject(name: result.split('/').last, rootPath: result),
          );

          appWindow.size = editorSize;
          context.go("/project?path=$result", extra: result);
        })
        .catchError((error) {
          print("Error picking project: $error");
        });
  }
}
