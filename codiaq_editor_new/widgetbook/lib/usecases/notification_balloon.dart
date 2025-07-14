import 'package:codiaq_editor/ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: CQNotificationBalloon)
Widget buildNotificationBalloon(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: CQNotificationBalloon.popup(
      "Simple Balloon",
      "This is a simple notification balloon.",
      icon: Icon(Icons.info_outlined, color: Colors.white),
      actions: [
        CQButton.secondary(label: "Open Editor"),
        CQLink(text: "Dont show again"),
      ],
    ),
  );
}
