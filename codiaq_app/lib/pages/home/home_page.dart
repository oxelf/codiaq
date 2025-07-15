import 'package:bitsdojo_window/bitsdojo_window.dart';
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
  @override
  Widget build(BuildContext context) {
    var theme = EditorThemeProvider.of(context);
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
                Container(
                  constraints: BoxConstraints(maxWidth: 400),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: InputField(
                      prefixIcon: Icon(
                        Icons.search,
                        color: theme.iconTheme.color,
                      ),
                    ),
                  ),
                ),
                Row(
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
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(color: theme.dividerColor, height: 1.5),
          ),
        ],
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
          context.go("/project?path=$result", extra: result);
        })
        .catchError((error) {
          print("Error picking project: $error");
        });
  }
}
