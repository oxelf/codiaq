import 'package:codiaq_editor/ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: InputField)
Widget buildInputField(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: SizedBox(width: 300, child: InputField()),
  );
}

@widgetbook.UseCase(name: 'Suffix', type: InputField)
Widget buildInputFieldWithSuffix(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: SizedBox(
      width: 300,
      child: InputField(suffixIcon: const Icon(Icons.expand_more_outlined)),
    ),
  );
}

@widgetbook.UseCase(name: 'Prefix', type: InputField)
Widget buildInputFieldWithPrefix(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: SizedBox(
      width: 300,
      child: InputField(prefixIcon: const Icon(Icons.search_outlined)),
    ),
  );
}
