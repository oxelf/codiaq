import 'dart:convert';

import 'package:xterm/xterm.dart';

import 'terminal_shell.dart';

import 'package:flutter_pty/flutter_pty.dart';

class DesktopTerminalShell implements TerminalShell {
  final Terminal terminal = Terminal();
  late final Pty _pty;

  @override
  Future<void> start() async {
    _pty = Pty.start('/bin/zsh'); // or 'zsh', 'cmd.exe', etc.

    // Pipe PTY output into the terminal
    _pty.output
        .cast<List<int>>() // comes in as bytes
        .transform(const Utf8Decoder()) // decode to String
        .listen(terminal.write);

    // Handle terminal user input
    terminal.onOutput = (data) {
      _pty.write(Utf8Encoder().convert(data));
    };

    // Optional: Handle resize events
    terminal.onResize = (width, height, _, __) {
      _pty.resize(height, width); // resize expects (rows, cols)
    };
  }

  @override
  void dispose() {
    _pty.write(Utf8Encoder().convert('exit\n'));
    _pty.kill();
    terminal.onOutput = null;
  }
}
