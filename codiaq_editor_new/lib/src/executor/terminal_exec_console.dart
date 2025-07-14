import 'package:xterm/xterm.dart';

import 'process_handler.dart';

class TerminalExecutionConsole {
  final Terminal terminal;
  final ProcessHandler handler;

  TerminalExecutionConsole({required this.handler, Terminal? terminalOverride})
    : terminal = terminalOverride ?? Terminal();

  Future<void> start() async {
    await handler.start();

    handler.stdout.listen((line) {
      print('STDOUT: $line');
      terminal.write('$line\n');
    });

    handler.stderr.listen((line) {
      print('stderr: $line');
      terminal.write('[stderr] $line\n');
    });

    handler.exitCode.then((code) {
      print('Process exited with code: $code');
      terminal.write('[Process exited ($code)]\n');
    });

    terminal.onOutput = (input) {
      print('Terminal input: $input');
      handler.write(input);
    };
  }

  void dispose() {
    terminal.write('[Session closed]\n');
    handler.kill();
    terminal.onOutput = null;
  }
}
