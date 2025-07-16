import 'dart:io';

import 'package:xterm/xterm.dart';

import 'desktop_terminal_shell.dart';
import 'mobile_terminal_shell.dart';

abstract class TerminalShell {
  Terminal get terminal;
  String? workingDirectory;

  Future<void> start();
  void dispose();

  factory TerminalShell.desktop() {
    return DesktopTerminalShell();
  }

  factory TerminalShell.mobile() {
    return MobileTerminalShell();
  }

  factory TerminalShell.platform() {
    if (Platform.isIOS) {
      return TerminalShell.mobile();
    } else {
      return TerminalShell.desktop();
    }
  }
}
