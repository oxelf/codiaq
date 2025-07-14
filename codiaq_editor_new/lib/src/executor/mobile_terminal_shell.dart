import 'package:xterm/xterm.dart';

import 'general_commandline.dart';
import 'mobile_process_handler.dart';
import 'terminal_exec_console.dart';
import 'terminal_shell.dart';

class MobileTerminalShell implements TerminalShell {
  final Terminal terminal = Terminal();
  late final TerminalExecutionConsole _console;

  @override
  Future<void> start() async {
    final handler = MobileProcessHandler(
      GeneralCommandLine('sh'),
    ); // mock or native shell
    _console = TerminalExecutionConsole(
      handler: handler,
      terminalOverride: terminal,
    );
    await _console.start();
  }

  @override
  void dispose() {
    _console.dispose();
  }
}
