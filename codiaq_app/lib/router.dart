import 'package:codiaq_app/pages/home/home_page.dart';
import 'package:codiaq_editor/codiaq_editor.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// GoRouter configuration
final router = GoRouter(
  errorBuilder: (context, state) {
    // Handle errors here, e.g., show an error page
    return Scaffold(
      body: Center(
        child: Text(
          'Error: ${state.error}',
          style: TextStyle(color: Colors.red, fontSize: 24),
        ),
      ),
    );
  },
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => NoTransitionPage(child: HomePage()),
    ),
    GoRoute(
      path: '/project',
      pageBuilder: (context, state) {
        print("state.extra: ${state.extra}");
        var theme = EditorTheme(
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

        late Project project = Project(
          name: "Codiaq Editor Example",
          rootPath:
              state.extra as String? ??
              "/Users/joscha/Documents/dev/codiaq_editor_new",
          theme: theme,
        );

        project.keymapManager.registerAllShortcuts(macosDefaultKeymap);
        project.highlightGroups.registerMany(intellijDarkHgroups);

        Future<void> addLsp() async {
          StdioLspClient client = StdioLspClient(
            serverId: "dart_lsp",
            command: "dart",
            args: ["language-server"],
          );
          client.start();
          Future.delayed(Duration(milliseconds: 1000), () async {
            await client.initialize(
              rootUri: Uri.file(project.rootPath).toString(),
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

            project.addLspClient(client);
            print("Initialized LSP client: ${client.serverId}");
            await Future.delayed(Duration(milliseconds: 1000));

            //client.attach(buffer);
            //buffer.lsp.registerClient(client);
          });
        }

        try {
          addLsp();
        } catch (e) {
          print("Error initializing LSP client: $e");
        }

        return NoTransitionPage(
          child: Scaffold(body: ProjectIDE(project: project)),
        );
      },
    ),
  ],
);
