import 'package:codiaq_editor/ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Checked', type: CQCheckbox)
Widget buildCheckedCheckbox(BuildContext context) {
  CheckboxState state = CheckboxState.checked;
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: StatefulBuilder(
      builder: (context, setState) {
        return CQCheckbox(
          state: state,
          onTap: (oldState) {
            if (oldState == CheckboxState.checked) {
              setState(() => state = CheckboxState.indeterminate);
            } else if (oldState == CheckboxState.indeterminate) {
              setState(() => state = CheckboxState.unchecked);
            } else {
              setState(() => state = CheckboxState.checked);
            }
          },
        );
      },
    ),
  );
}

@widgetbook.UseCase(name: 'Disabled', type: CQCheckbox)
Widget buildDisabledCheckbox(BuildContext context) {
  CheckboxState state = CheckboxState.disabled;
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: StatefulBuilder(
      builder: (context, setState) {
        return CQCheckbox(state: state, onTap: (oldState) {});
      },
    ),
  );
}
