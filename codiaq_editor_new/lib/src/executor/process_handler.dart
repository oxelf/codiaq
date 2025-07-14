import 'dart:io';

import 'desktop_process_handler.dart';
import 'general_commandline.dart';
import 'mobile_process_handler.dart';

abstract class ProcessHandler {
  Future<void> start();

  void kill();

  Stream<String> get stdout;
  Stream<String> get stderr;
  Future<int> get exitCode;
  void write(String data);

  factory ProcessHandler.create(GeneralCommandLine commandLine) {
    if (Platform.isIOS) {
      return MobileProcessHandler(commandLine);
    } else {
      return DesktopProcessHandler(commandLine);
    }
  }
}
