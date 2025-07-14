import 'package:flutter/material.dart';

import 'data.dart';

Widget getSetiIcon(
  String filename, {
  double size = 16,
  Color fallbackColor = Colors.white,
}) {
  const fontFamily = 'Seti';

  final ext = _getExtension(filename);
  final meta = iconSetMap[ext];

  if (meta != null) {
    return Icon(
      IconData(meta.codePoint, fontFamily: fontFamily),
      color: Color(meta.color),
      size: size,
    );
  }

  // fallback
  return Icon(
    Icons.insert_drive_file,
    size: size,
    color: fallbackColor,
    semanticLabel: 'File icon for $filename',
  );
}

String _getExtension(String filename) {
  final name = filename.toLowerCase();
  final dotIndex = name.lastIndexOf('.');
  return dotIndex != -1 ? name.substring(dotIndex) : '';
}
