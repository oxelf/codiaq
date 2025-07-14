import 'package:flutter/widgets.dart';

enum Anchor { bottomLeft, bottomRight, left, right }

class ToolWindow {
  final String name;
  final Widget content;
  final Widget icon;
  final Widget? titleBar;
  Anchor anchor;
  bool isVisible;
  bool isActive;

  ToolWindow({
    required this.name,
    required this.content,
    required this.icon,
    this.titleBar,
    this.anchor = Anchor.bottomLeft,
    this.isVisible = true,
    this.isActive = false,
  });
}
