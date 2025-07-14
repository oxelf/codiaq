import 'package:codiaq_editor/src/ui/cq_widgets/icon_button.dart';
import 'package:flutter/material.dart';

import '../actions/action.dart';
import '../actions/action_event.dart';

class SettingsIconAction extends EditorAction {
  SettingsIconAction()
    : super(
        icon: CQIconButton(onPressed: () {}, icon: Icons.settings_outlined),
        label: "Settings",
        description: "Open settings dialog",
        actionIdentifier: "settings",
      );

  @override
  void performAction(ActionEvent event) {
    // Implement the settings functionality here
    print("Settings action performed");
  }
}
