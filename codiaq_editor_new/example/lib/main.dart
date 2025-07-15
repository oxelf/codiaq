import 'dart:async';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:codiaq_editor/codiaq_editor.dart' as cq;
import 'package:codiaq_editor/codiaq_editor.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (!Platform.isAndroid && !Platform.isIOS) {
    doWhenWindowReady(() {
      const initialSize = Size(1080, 720);
      const minSize = Size(600, 800);
      appWindow.minSize = minSize;
      appWindow.size = initialSize;
      appWindow.alignment = Alignment.center;
      appWindow.show();
    });
  }
  try {
    runApp(const MainApp());
  } catch (e) {
    print('Error in main: $e');
  }
}

class CopyAction extends cq.EditorAction {
  CopyAction({super.actionIdentifier = "buffer.copy"});

  @override
  void performAction(cq.ActionEvent event) {
    print("COPY ACTION PERFORMED");
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  var theme = cq.EditorTheme(
    // intellij background color
    backgroundColor: Color(0xFF1E1F22),
    //baseStyle: const TextStyle(
    //  color: Colors.white,
    //  fontFamily: 'JetBrainsMono',
    //  package: "codiaq_editor",
    //  fontSize: 20,
    //),
    dividerColor: Color.fromARGB(255, 57, 59, 64),
    popupBackgroundColor: Color(0xFF2B2D30),
    showBreakpoints: true,
    relativeLineNumbers: false,
    cursorColor: Colors.white70,
    selectionColor: Colors.blue.withOpacity(0.3),
  );

  late cq.Project project = cq.Project(
    name: "Codiaq Editor Example",
    rootPath: "/Users/joscha/Documents/dev/codiaq_editor_new",
    theme: theme,
  );

  @override
  void initState() {
    project.keymapManager.registerAllShortcuts(macosDefaultKeymap);
    WidgetsBinding.instance.addPostFrameCallback((_) {});

    cq.StdioLspClient client = cq.StdioLspClient(
      serverId: "dart_lsp",
      command: "dart",
      args: ["language-server"],
    );
    client.start();
    Future.delayed(Duration(milliseconds: 1000), () async {
      client.initialize(
        rootUri:
            Uri.file(
              "/Users/joscha/Documents/dev/codiaq_editor_new/example",
            ).toString(),
        capabilities: {
          "textDocument": {
            "hover": {"dynamicRegistration": true},
            "completion": {"dynamicRegistration": true},
            "definition": {"dynamicRegistration": true},
            "references": {"dynamicRegistration": true},
            "documentSymbol": {"dynamicRegistration": true},
            "codeAction": {
              "codeActionLiteralSupport": {
                "codeActionKind": {
                  "valueSet": [
                    "",
                    "quickfix",
                    "refactor",
                    "refactor.extract",
                    "refactor.inline",
                    "refactor.rewrite",
                    "source",
                    "source.organizeImports",
                  ],
                },
              },
            },
          },
          "workspace": {
            "applyEdit": true,
            "workspaceEdit": {"documentChanges": true},
          },
        },
        pid: 123,
      );
      await Future.delayed(Duration(milliseconds: 1000));

      project.addLspClient(client);
      print("Initialized LSP client: ${client.serverId}");
      //client.attach(buffer);
      //buffer.lsp.registerClient(client);
    });
    //window.pluginManager.registerPlugin(cq.DartAnalyzerPlugin());
    project.highlightGroups.registerMany(intellijDarkHgroups);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: EditorThemeProvider(
          theme: theme,
          child: ProjectIDE(project: project),
        ),
      ),
    );
  }
}
