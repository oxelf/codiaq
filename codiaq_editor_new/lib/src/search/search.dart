import 'package:codiaq_editor/src/ui/cq_widgets/icon_button.dart';
import 'package:flutter/material.dart';

import '../actions/action.dart';
import '../actions/action_event.dart';

class SearchIconAction extends EditorAction {
  SearchIconAction()
    : super(
        icon: CQIconButton(onPressed: () {}, icon: Icons.search_outlined),
        label: "Search",
        description: "Open search dialog",
        actionIdentifier: "search",
      );

  @override
  void performAction(ActionEvent event) {
    // Implement the search functionality here
    print("Search action performed");
  }
}
