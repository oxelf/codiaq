//import 'package:codiaq_editor/codiaq_editor.dart';
//import 'package:codiaq_editor/src/api/editor_api.dart';
//import 'package:codiaq_editor/src/plugin/window_plugin.dart';
//
//class WindowPluginManager {
//  final List<WindowPluginBase> _plugins = [];
//  final Window window;
//
//  WindowPluginManager(this.window) {
//    window.buffer.events.addListener((event) {
//      if (event.type == BufferEventType.modified.index ||
//          event.type == BufferEventType.inserted.index ||
//          event.type == BufferEventType.deleted.index) {
//        notifyPlugins("linesChanged", {});
//      }
//    });
//  }
//
//  void registerPlugin(WindowPluginBase plugin) {
//    _plugins.add(plugin);
//    plugin.register(WindowApi(window));
//  }
//
//  void unregisterPlugin(String pluginName) {
//    _plugins.removeWhere((plugin) => plugin.name == pluginName);
//  }
//
//  void notifyPlugins(String event, Map<String, dynamic> data) {
//    var notifyEvents = [
//      "linesChanged",
//      "cursorChanged",
//      "popupChanged",
//      "undo",
//      "redo",
//      "fileTypeChanged",
//      "typing",
//    ];
//    if (notifyEvents.contains(event)) {
//      for (var plugin in _plugins) {
//        switch (event) {
//          case "linesChanged":
//            plugin.onLinesChanged();
//            break;
//          case "cursorChanged":
//            plugin.onCursorChanged();
//            break;
//          case "popupChanged":
//            plugin.onPopupChanged();
//            break;
//          case "undo":
//            plugin.onUndo();
//            break;
//          case "redo":
//            plugin.onRedo();
//            break;
//          case "typing":
//            plugin.onTyping();
//            break;
//          case "fileTypeChanged":
//            if (data.containsKey("filetype")) {
//              plugin.onFileTypeChanged(data["filetype"]);
//            }
//            break;
//        }
//      }
//    }
//  }
//
//  List<WindowPluginBase> get plugins => List.unmodifiable(_plugins);
//}
