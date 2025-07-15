import 'dart:async';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:codiaq_app/router.dart';
import 'package:codiaq_editor/codiaq_editor.dart' as cq;
import 'package:codiaq_ui/codiaq_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const homeSize = Size(800, 650);
const editorSize = Size(1400, 1000);

var editorTheme = cq.EditorTheme(
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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Timer.periodic(Duration(seconds: 1), (timer) {
    print("window size: ${appWindow.size}");
  });
  if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS) {
    doWhenWindowReady(() {
      //const minSize = Size(600, 800);
      //appWindow.minSize = minSize;
      appWindow.size = homeSize;
      print("App window size: ${appWindow.size}");
      print("app window position: ${appWindow.position}");
      print("app window alignment: ${appWindow.alignment}");
      print("app window is maximized: ${appWindow.rect}");
      appWindow.alignment = Alignment.center;
      appWindow.show();
    });
  }
  try {
    runApp(const CodiaqMainApp());
  } catch (e) {
    print('Error in main: $e');
  }
}

class CodiaqMainApp extends StatefulWidget {
  const CodiaqMainApp({super.key});

  @override
  State<CodiaqMainApp> createState() => _CodiaqMainAppState();
}

class _CodiaqMainAppState extends State<CodiaqMainApp> {
  @override
  Widget build(BuildContext context) {
    return CQTheme(
      theme: CQThemeData(),
      child: cq.EditorThemeProvider(
        theme: editorTheme,
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          //title: 'Codiaq Editor Example',
          //theme: ThemeData(
          //  primarySwatch: Colors.blue,
          //  visualDensity: VisualDensity.adaptivePlatformDensity,
          //),
          routerConfig: router,
        ),
      ),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late cq.Project project = cq.Project(
    name: "Codiaq Editor Example",
    rootPath: "/Users/joscha/Documents/dev/codiaq_editor_new",
    theme: editorTheme,
  );

  @override
  void initState() {
    project.keymapManager.registerAllShortcuts(cq.macosDefaultKeymap);
    WidgetsBinding.instance.addPostFrameCallback((_) {});

    cq.StdioLspClient client = cq.StdioLspClient(
      serverId: "dart_lsp",
      command: "dart",
      args: ["language-server"],
    );
    client.start();
    Future.delayed(Duration(milliseconds: 1000), () async {
      client.initialize(
        rootUri: Uri.file(
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
    project.highlightGroups.registerMany(cq.intellijDarkHgroups);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: cq.EditorThemeProvider(
          theme: editorTheme,
          child: cq.ProjectIDE(project: project),
        ),
      ),
    );
  }
}
