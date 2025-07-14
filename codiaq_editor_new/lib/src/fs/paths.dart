import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Paths {
  static String _appName = 'codiaq';

  static Future<String> getConfigPath() async {
    if (Platform.isLinux || Platform.isMacOS) {
      final configHome = Platform.environment['XDG_CONFIG_HOME'];
      if (configHome != null && configHome.isNotEmpty) {
        return '$configHome/$_appName';
      }
      final home = Platform.environment['HOME'] ?? '.';
      return '$home/.config/$_appName';
    } else if (Platform.isWindows) {
      final localAppData = Platform.environment['LOCALAPPDATA'] ?? '.';
      return '$localAppData\\$_appName\\config';
    } else if (Platform.isAndroid || Platform.isIOS) {
      final dir = await getApplicationSupportDirectory();
      return dir.path;
    } else {
      final temp = Directory.systemTemp.path;
      return temp;
    }
  }

  static Future<String> getDataPath() async {
    if (Platform.isLinux || Platform.isMacOS) {
      final dataHome = Platform.environment['XDG_DATA_HOME'];
      if (dataHome != null && dataHome.isNotEmpty) {
        return '$dataHome/$_appName';
      }
      final home = Platform.environment['HOME'] ?? '.';
      return '$home/.local/share/$_appName';
    } else if (Platform.isWindows) {
      final localAppData = Platform.environment['LOCALAPPDATA'] ?? '.';
      return '$localAppData\\$_appName\\data';
    } else if (Platform.isAndroid || Platform.isIOS) {
      final dir = await getApplicationSupportDirectory();
      return dir.path;
    } else {
      final temp = Directory.systemTemp.path;
      return temp;
    }
  }

  static Future<String> getCachePath() async {
    if (Platform.isLinux || Platform.isMacOS) {
      final cacheHome = Platform.environment['XDG_CACHE_HOME'];
      if (cacheHome != null && cacheHome.isNotEmpty) {
        return '$cacheHome/$_appName';
      }
      final home = Platform.environment['HOME'] ?? '.';
      return '$home/.cache/$_appName';
    } else if (Platform.isWindows) {
      final localAppData = Platform.environment['LOCALAPPDATA'] ?? '.';
      return '$localAppData\\$_appName\\cache';
    } else if (Platform.isAndroid || Platform.isIOS) {
      final dir = await getTemporaryDirectory();
      return dir.path;
    } else {
      final temp = Directory.systemTemp.path;
      return temp;
    }
  }
}
