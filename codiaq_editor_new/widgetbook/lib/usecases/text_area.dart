import 'package:codiaq_editor/ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: TextArea)
Widget buildInputField(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: SizedBox(width: 300, child: TextArea(expands: true)),
  );
}

@widgetbook.UseCase(name: 'Expand Icon', type: TextArea)
Widget buildInputFieldWithSuffix(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: SizedBox(width: 300, child: TextArea(minLines: 1, maxLines: 5)),
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
