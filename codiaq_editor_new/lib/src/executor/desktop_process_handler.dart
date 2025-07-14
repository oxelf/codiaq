import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'general_commandline.dart';
import 'process_handler.dart';

class DesktopProcessHandler implements ProcessHandler {
  final GeneralCommandLine commandLine;
  late Process _process;

  final _stdoutController = StreamController<String>();
  final _stderrController = StreamController<String>();
  final _exitCodeCompleter = Completer<int>();

  DesktopProcessHandler(this.commandLine);

  @override
  Future<void> start() async {
    _process = await Process.start(
      commandLine.executable,
      commandLine.arguments,
      workingDirectory: commandLine.workingDirectory,
      environment: commandLine.environment,
      runInShell: true,
    );
    print('Starting process: ${commandLine.fullCommand.join(" ")}');

    _process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(_stdoutController.add);

    _process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(_stderrController.add);

    _process.exitCode.then(_exitCodeCompleter.complete);
  }

  @override
  void write(String data) {
    _process.stdin.write(data);
    if (!data.endsWith('\n')) {
      _process.stdin.flush(); // Ensure newline for terminal commands
    }
  }

  @override
  void kill() {
    _process.kill(ProcessSignal.sigterm);
  }

  @override
  Stream<String> get stdout => _stdoutController.stream;

  @override
  Stream<String> get stderr => _stderrController.stream;

  @override
  Future<int> get exitCode => _exitCodeCompleter.future;
}
