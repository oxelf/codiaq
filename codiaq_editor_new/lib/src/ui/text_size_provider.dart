import 'package:flutter/widgets.dart';

class TextSizeProvider extends InheritedWidget {
  final double fontSize;

  const TextSizeProvider({
    Key? key,
    required this.fontSize,
    required Widget child,
  }) : super(key: key, child: child);

  static double of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<TextSizeProvider>();
    if (provider == null) {
      throw FlutterError('TextSizeProvider not found in context');
    }
    return provider.fontSize;
  }

  @override
  bool updateShouldNotify(TextSizeProvider oldWidget) =>
      fontSize != oldWidget.fontSize;
}
