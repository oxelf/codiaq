import 'package:codiaq_editor/ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: CQLink)
Widget buildLink(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: CQLink(text: "Default Link"),
  );
}

@widgetbook.UseCase(name: 'Dropdown', type: CQLink)
Widget buildDropdownLink(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: CQLink.dropdown(text: "Default Link"),
  );
}

@widgetbook.UseCase(name: 'Disabled', type: CQLink)
Widget builDisabledLink(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: CQLink(text: "Disabled Link", disabled: true, onTap: () {}),
  );
}
