import 'package:flutter/widgets.dart';

import '../theme/theme.dart';

class EditorThemeProvider extends InheritedWidget {
  final EditorTheme theme;

  const EditorThemeProvider({
    Key? key,
    required this.theme,
    required Widget child,
  }) : super(key: key, child: child);

  static EditorTheme of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<EditorThemeProvider>();
    if (provider == null) {
      throw FlutterError('EditorThemeProvider not found in context');
    }
    return provider.theme;
  }

  @override
  bool updateShouldNotify(EditorThemeProvider oldWidget) =>
      theme.hashCode != oldWidget.theme.hashCode;
}
