import 'dart:async';

import 'general_commandline.dart';
import 'process_handler.dart';

class MobileProcessHandler implements ProcessHandler {
  final GeneralCommandLine commandLine;

  final _stdoutController = StreamController<String>();
  final _stderrController = StreamController<String>();
  final _exitCodeCompleter = Completer<int>();

  MobileProcessHandler(this.commandLine);

  @override
  Future<void> start() async {
    // Simulated execution. Replace with actual mobile exec logic.
    Future.delayed(Duration(milliseconds: 100), () {
      _stdoutController.add(
        'Mobile: Running ${commandLine.fullCommand.join(" ")}',
      );
      _exitCodeCompleter.complete(0);
    });
  }

  @override
  void kill() {
    // Implement cancellation if needed
  }
  @override
  void write(String data) {}

  @override
  Stream<String> get stdout => _stdoutController.stream;

  @override
  Stream<String> get stderr => _stderrController.stream;

  @override
  Future<int> get exitCode => _exitCodeCompleter.future;
}
