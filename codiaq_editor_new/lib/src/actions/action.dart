import 'package:codiaq_editor/src/actions/action_event.dart';
import 'package:flutter/widgets.dart';

enum EditorActionLocation { statusBar, toolBar, editor, none }

class ActionGroup extends ChangeNotifier {
  String name;
  List<EditorAction> actions = [];

  ActionGroup({required this.name});

  void addAction(EditorAction action) {
    actions.add(action);
    notifyListeners();
  }

  void removeAction(EditorAction action) {
    actions.remove(action);
    notifyListeners();
  }

  void clearActions() {
    actions.clear();
    notifyListeners();
  }

  void removeActionByIdentifier(String identifier) {
    actions.removeWhere((action) => action.actionIdentifier == identifier);
    notifyListeners();
  }
}

abstract class EditorAction {
  Widget? icon;
  String? label;
  String? description;
  String actionIdentifier;

  void performAction(ActionEvent event);

  EditorAction({
    this.icon,
    this.label,
    this.description,
    required this.actionIdentifier,
  });
}
