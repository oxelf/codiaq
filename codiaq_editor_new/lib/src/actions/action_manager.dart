import 'package:flutter/material.dart';

import 'action.dart';

// Intellijs Action Groups:

//MainToolbar The main toolbar at the top of the IDE
//MainMenu The main menu bar (File, Edit, View, etc.)
//EditorPopupMenu Right-click (context) menu inside the code editor
//ProjectViewPopupMenu Right-click menu in the Project tool window
//FavoritesViewPopupMenu Right-click menu in the Favorites tool window
//StructureViewPopupMenu Right-click menu in the Structure tool window
//ChangesViewPopupMenu Right-click menu in the Version Control / Changes view
//ToolWindowPopupGroup Toolbar for tool windows
//DebuggerPopupMenu Debugger context menus
//RunToolbar Toolbar shown in the run/debug tool window
//EditorTabPopupMenu Right-click on editor tabs
//EditorGutterPopupMenu Right-click on the editor gutter (line numbers, breakpoints)
//EditorTabActions Toolbar actions available on editor tabs
//NavigationBarToolbar Toolbar shown above editor when Navigation Bar is enabled
//FindPopupMenu Right-click in Find Tool Window
//VersionControlToolbar Top actions in the Version Control tab

class ActionManager extends ChangeNotifier {
  final Map<String, ActionGroup> _actionGroups;

  void registerAction(String groupName, EditorAction action) {
    if (!_actionGroups.containsKey(groupName)) {
      throw ArgumentError(
        'Action group "$groupName" is not registered. Please register it first.',
      );
    }
    print(
      "Registering action: ${action.actionIdentifier} in group: $groupName (${_actionGroups[groupName]!.hashCode})",
    );
    _actionGroups[groupName]!.addAction(action);
  }

  void unregisterAction(String groupName, EditorAction action) {
    if (_actionGroups.containsKey(groupName)) {
      _actionGroups[groupName]!.removeAction(action);
      if (_actionGroups[groupName]!.actions.isEmpty) {
        _actionGroups.remove(groupName);
      }
    }
  }

  ActionGroup? getActionGroup(String groupName) {
    return _actionGroups[groupName];
  }

  List<ActionGroup> get actionGroups => _actionGroups.values.toList();

  void clear() {
    _actionGroups.clear();
    notifyListeners();
  }

  ActionManager()
    : _actionGroups = {
        //"leftToolbar": ActionGroup(name: "leftToolbar"),
        //"rightToolbar": ActionGroup(name: "rightToolbar"),
        //"bottomLeftToolbar": ActionGroup(name: "bottomLeftToolbar"),
        //"bottomRightToolbar": ActionGroup(name: "bottomRightToolbar"),
        "mainToolbarActions": ActionGroup(name: "mainToolbarActions"),
        "mainToolbar": ActionGroup(name: "mainToolbar"),
      };
}
