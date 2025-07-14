import 'package:codiaq_editor/codiaq_editor.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: ToolWindowsTest()));
}

class ToolWindowsTest extends StatefulWidget {
  const ToolWindowsTest({super.key});

  @override
  State<ToolWindowsTest> createState() => _ToolWindowsTestState();
}

class _ToolWindowsTestState extends State<ToolWindowsTest> {
  ToolWindowManager manager = ToolWindowManager();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      manager.registerToolWindow(
        "terminal",
        ToolWindow(
          id: "terminal",
          content: Container(
            color: Colors.red,
            child: const Center(child: Text("Terminal Window")),
          ),
          anchor: Anchor.bottomLeft,
        ),
      );
      Scaff

       manager.registerToolWindow(
        "fileExplorer",
        ToolWindow(
          id: "fileExplorer",
          content: Container(
            color: Colors.green,
            child: const Center(child: Text("File Explorer")),
          ),
          anchor: Anchor.leftTop,
        ),
      );
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tool Windows Test')),
      body: ToolWindowWrapper(
        toolWindowManager: manager,
        child: Container(color: Colors.blue, child: Text('Main Content Area')),
      ),
    );
  }
}
