import 'package:codiaq_editor/ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Primary', type: CQButton)
Widget buildPrimaryButton(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: CQButton(label: "Primary"),
  );
}

@widgetbook.UseCase(name: 'Secondary', type: CQButton)
Widget buildSecondaryButton(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: CQButton.secondary(label: "Secondary"),
  );
}

@widgetbook.UseCase(name: 'Disabled', type: CQButton)
Widget buildDisabledButton(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: CQButton.secondary(label: "Disabled", disabled: true),
  );
}

//@widgetbook.UseCase(name: '', type: TextArea)
//Widget buildInputFieldWithPrefix(BuildContext context) {
//  return Padding(
//    padding: const EdgeInsets.all(8.0),
//    child: SizedBox(
//      width: 300,
//      child: TextArea(prefixIcon: const Icon(Icons.search_outlined)),
//    ),
//  );
//}
