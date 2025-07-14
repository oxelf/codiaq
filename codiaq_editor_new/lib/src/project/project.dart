import 'dart:async';
import 'dart:io';

import 'package:codiaq_editor/codiaq_editor.dart';
import 'package:codiaq_editor/src/actions/action_manager.dart';
import 'package:codiaq_editor/src/actions/keymap_manager.dart';
import 'package:codiaq_editor/src/executor/shell_manager.dart';
import 'package:codiaq_editor/src/project/diagnostics.dart';
import 'package:codiaq_editor/src/settings/settings.dart';
import 'package:codiaq_editor/src/ui/terminal_tabs.dart';
import 'package:codiaq_editor/src/ui/undo_tree.dart';
import 'package:flutter/material.dart';

import '../search/search.dart';
import '../window/cursor.dart';

class Project {
  final String name;
  final String rootPath;
  final List<Buffer> buffers = [];
  ToolWindowManager toolWindowManager = ToolWindowManager();
  final EditorTheme theme;
  final List<LspClient> lspClients = [];
  final FSProvider fsProvider;
  late final FileExplorerCache fileExplorerCache = FileExplorerCache(
    fsProvider,
  );
  final HighlightGroupManager highlightGroups = HighlightGroupManager();
  ProjectDiagnostics diagnostics = ProjectDiagnostics();
  final ValueNotifier<int> currentBuffer = ValueNotifier<int>(0);
  final ShellManager shellManager = ShellManager();
  final KeymapManager keymapManager = KeymapManager();
  final ActionManager actionManager = ActionManager();

  Project({
    required this.name,
    required this.rootPath,
    this.theme = const EditorTheme(),
    this.fsProvider = const LocalFSProvider(),
  }) {
    initialize();
  }

  Future<void> openBuffer(String path, {bool focus = true}) async {
    if (buffers.any((b) => b.path == path)) {
      print("Buffer already open: $path");
      currentBuffer.value = buffers.indexWhere((b) => b.path == path);
      return;
    }
    var file = fsProvider.readAsStringSync(path);
    final buffer = Buffer(
      theme: theme,
      filetype: path.split(".").last,
      initialLines: file.split('\n'),
      hgMgr: highlightGroups,
    );

    buffer.path = path;
    buffer.focusNode.addListener(() {
      if (buffer.focusNode.hasFocus) {
        currentBuffer.value = buffers.indexOf(buffer);
      } else {
        // save file when focus is lost
        fsProvider.writeAsString(path, buffer.lines.getText());
      }
    });
    buffer.diagnostics.setDiagnostics(diagnostics.getDiagnosticsForFile(path));
    buffer.inputHandler.keymapManager = keymapManager;
    for (var client in lspClients) {
      client.attach(buffer);
      buffer.lsp.registerClient(client);
    }
    buffers.add(buffer);
    if (focus) currentBuffer.value = buffers.length - 1;
    print("opened buffer: $path, with filetype: ${buffer.filetype}");
  }

  Future<void> initialize() async {
    print("Initializing project: $name at $rootPath");
    initActions();
    initToolWindows();
    fsProvider.watch(rootPath, recursive: true).listen((event) {
      if (event.type == FsEventType.modified) {
        var path = event.path;
        String content = fsProvider.readAsStringSync(path);
        print("File modified: $path");
        var buffer = buffers.firstWhere(
          (b) => b.path == path,
          orElse:
              () => Buffer(
                theme: theme,
                filetype: "unknown",
                initialLines: [],
                hgMgr: highlightGroups,
              ),
        );
        buffer.lines.setLines(content.split('\n'));
      } else if (event.type == FsEventType.deleted) {
        var path = event.path;
        print("File deleted: $path");
        buffers.removeWhere((b) => b.path == path);
      }
    });
    if (fsProvider.existsSync("$rootPath/README.md")) {
      await openBuffer("$rootPath/README.md");
      openBuffer("$rootPath/example/lib/main.dart", focus: false);
    } else {
      print("No README.md found in $rootPath");
    }
  }

  Future<void> initActions() async {
    print("Initializing actions for project: $name");
    actionManager.registerAction("mainToolbarActions", SearchIconAction());
    actionManager.registerAction("mainToolbarActions", SettingsIconAction());
  }

  Future<void> initToolWindows() async {
    toolWindowManager.registerToolWindow(
      "terminal",
      ToolWindow(
        name: "Terminal",
        icon: Icon(Icons.terminal),
        content: SizedBox.expand(
          child: CurrentTerminalWidget(shellManager: shellManager),
        ),
        titleBar: TerminalTabBarWidget(shellManager: shellManager),
        anchor: Anchor.bottomLeft,
        isVisible: true,
      ),
    );

    toolWindowManager.registerToolWindow(
      "problems",
      ToolWindow(
        name: "Problems",
        icon: Icon(Icons.error_outline),
        content: SizedBox.expand(
          child: ListenableBuilder(
            listenable: diagnostics,
            builder: (context, _) {
              return ProblemsTabWidget(
                diagnostics: diagnostics.allDiagnostics,
                onDiagnosticClick: (path, diagnostic) {
                  // Handle diagnostic click, e.g., open file at line
                  print(
                    "Clicked diagnostic in $path at line ${diagnostic.line}",
                  );
                  String sanitizedPath = path.substring(7);
                  openBuffer(sanitizedPath);
                  buffers.forEach((b) {
                    print("Buffer path: ${b.path}");
                  });
                  print("Sanitized path: $sanitizedPath");
                  var buffer = buffers.firstWhere(
                    (b) => b.path == sanitizedPath,
                    orElse:
                        () => Buffer(
                          theme: theme,
                          filetype: "unknown",
                          initialLines: [],
                          hgMgr: highlightGroups,
                        ),
                  );
                  print("Buffer found: ${buffer.path}");
                  buffer.viewport.revealPos(
                    diagnostic.line,
                    diagnostic.startCol,
                  );
                  buffer.setCursorPosition(
                    diagnostic.line,
                    diagnostic.startCol,
                  );
                  buffer.focusNode.requestFocus();
                },
              );
            },
          ),
        ),
        anchor: Anchor.bottomRight,
      ),
    );

    toolWindowManager.registerToolWindow(
      "fileExplorer",
      ToolWindow(
        name: "File Explorer",
        icon: Icon(Icons.folder_outlined),
        content: SizedBox.expand(
          child: FileExplorer(
            cache: fileExplorerCache,
            theme: theme,
            rootPath: rootPath,
            onPathSelected: (path) async {
              await openBuffer(path);
            },
          ),
        ),
        anchor: Anchor.left,
      ),
    );

    toolWindowManager.registerToolWindow(
      "copilot",
      ToolWindow(
        name: "Copilot",
        icon: Icon(Icons.chat_bubble),
        content: SizedBox.expand(child: Container(color: Colors.green)),
        anchor: Anchor.right,
        isVisible: false,
      ),
    );

    //toolWindowManager.registerToolWindow(
    //  "undotree",
    //  ToolWindow(
    //    name: "Undo Tree",
    //    icon: Icon(Icons.history),
    //    content: SizedBox.expand(
    //      child: Builder(
    //        builder: (context) {
    //          return UndoTreeVisualizer(
    //            buffer:
    //                buffers.isNotEmpty
    //                    ? buffers[currentBuffer.value]
    //                    : Buffer(
    //                      theme: theme,
    //                      filetype: "unknown",
    //                      initialLines: [],
    //                      hgMgr: highlightGroups,
    //                    ),
    //          );
    //        },
    //      ),
    //    ),
    //    anchor: Anchor.right,
    //    isVisible: false,
    //  ),
    //);
  }

  Future<void> closeBuffer(Buffer buffer) async {
    buffers.remove(buffer);
    print("closed buffer: ${buffer.path}");
  }

  Future<void> addLspClient(LspClient client) async {
    lspClients.add(client);
    client.messages.listen((message) {
      // diagnostics
      if (message["method"] == "textDocument/publishDiagnostics") {
        print("Received diagnostics for ${message["params"]["uri"]}");
        var params = message["params"];
        var uri = params["uri"];
        var diagnostics = params["diagnostics"] as List<dynamic>;
        var diags =
            diagnostics
                .map(
                  (d) =>
                      Diagnostic.fromLspDiagnostic(d as Map<String, dynamic>),
                )
                .toList();
        print("diagnostics: $diags");
        var buf = buffers.firstWhere(
          (b) => b.path == uri.substring(7), // Remove 'file://' prefix
          orElse:
              () => Buffer(
                theme: theme,
                filetype: "unknown",
                initialLines: [],
                hgMgr: highlightGroups,
              ),
        );
        buf.diagnostics.setDiagnostics(diags);
        this.diagnostics.replaceDiagnostics(uri, diags);
      }
    });
    for (var buffer in buffers) {
      client.attach(buffer);
      buffer.lsp.registerClient(client);
    }
  }

  Future<void> goto(
    String path, {
    int line = 0,
    int column = 0,
    CursorPosition? cursor,
  }) async {
    Buffer? buffer;
    if (path.isNotEmpty) {
      await openBuffer(path);
      buffer = buffers.firstWhere(
        (b) => b.path == path,
        orElse:
            () => Buffer(
              theme: theme,
              filetype: "unknown",
              initialLines: [],
              hgMgr: highlightGroups,
            ),
      );
      if (buffer.path != path) {
        print("Buffer not found for path: $path");
        return;
      }
    } else {
      return;
    }
    var gotoLine = line;
    var gotoColumn = column;
    if (cursor != null) {
      gotoLine = cursor.line;
      gotoColumn = cursor.column;
    }
    buffer.viewport.revealPos(gotoLine, gotoColumn);
  }
}
