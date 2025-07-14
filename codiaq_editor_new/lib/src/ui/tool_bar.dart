import 'dart:io' show Platform;
import 'package:codiaq_editor/src/icons/seti.dart';
import 'package:codiaq_editor/src/ui/cq_widgets/dropdown.dart';
import 'package:codiaq_editor/src/ui/cq_widgets/dropdown_button.dart';
import 'package:codiaq_editor/src/ui/cq_widgets/popup_menu.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:codiaq_editor/codiaq_editor.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ToolBarWidget extends StatefulWidget {
  final Project project;
  const ToolBarWidget({super.key, required this.project});

  @override
  State<ToolBarWidget> createState() => _ToolBarWidgetState();
}

class _ToolBarWidgetState extends State<ToolBarWidget> {
  bool get isDesktop =>
      !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

  bool get isMacOS => !kIsWeb && Platform.isMacOS;
  bool get isWindowsOrLinux =>
      !kIsWeb && (Platform.isWindows || Platform.isLinux);

  List<EditorAction> endActions = [];
  List<EditorAction> centerActions = [];

  @override
  void initState() {
    var endActionsGroup = widget.project.actionManager.getActionGroup(
      "mainToolbarActions",
    );
    if (endActionsGroup != null) {
      endActionsGroup.addListener(() {
        print("End actions updated: ${endActionsGroup.actions.length}");
        setState(() {
          endActions = endActionsGroup.actions;
        });
      });
      endActions = endActionsGroup.actions;
    }

    var centerActionsGroup = widget.project.actionManager.getActionGroup(
      "mainToolbar",
    );
    if (centerActionsGroup != null) {
      centerActionsGroup.addListener(() {
        print("Center actions updated: ${centerActionsGroup.actions.length}");
        setState(() {
          centerActions = centerActionsGroup.actions;
        });
      });
      centerActions = centerActionsGroup.actions;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure the toolbar is updated after the first frame
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.project.theme;

    final toolbar = Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: theme.secondaryBackgroundColor,
        border: Border(
          bottom: BorderSide(color: theme.backgroundColor, width: 3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isMacOS) const SizedBox(width: 72),

              if (!isMacOS)
                IconButton(icon: const Icon(Icons.menu), onPressed: () {}),

              getProjectName(),

              const SizedBox(width: 8),
              getBranch(),
              const SizedBox(width: 8),
            ],
          ),
          // Center actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children:
                centerActions.map((action) {
                  return action.icon != null
                      ? action.icon!
                      : Text(action.label ?? '');
                }).toList(),
          ),
          // RunActions
          // End actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children:
                endActions.map((action) {
                  return action.icon != null
                      ? action.icon!
                      : Text(action.label ?? '');
                }).toList(),
          ),

          //if (isWindowsOrLinux) const WindowButtonsRight(),
          //if (!isWindowsOrLinux)
          //  IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
    );

    return isDesktop
        ? SizedBox(
          height: 40,
          child: WindowTitleBarBox(child: MoveWindow(child: toolbar)),
        )
        : toolbar;
  }

  Widget getProjectName() {
    return Text(
      widget.project.name,
      style: TextStyle(
        color: widget.project.theme.baseStyle.color,
        fontSize: 14,
      ),
    );
  }

  Widget getBranch() {
    GlobalKey<PopupMenuButtonState> branchMenuKey =
        GlobalKey<PopupMenuButtonState>();
    return GestureDetector(
      onTap: () {
        var box =
            branchMenuKey.currentContext?.findRenderObject() as RenderBox?;
        var position =
            box?.localToGlobal(Offset.zero) ??
            Offset.zero; // Get the position of the button
        showPopupMenu(
          context,
          Offset(position.dx, position.dy + box!.size.height),
          [
            CQPopupMenuItemSimple(
              label: "Update Project",
              icon: Icon(MdiIcons.sourceBranchSync),
            ),
            CQPopupMenuItemSimple(
              label: "Commit",
              icon: Icon(MdiIcons.sourceCommit),
            ),
            CQPopupMenuItemSimple(
              label: "Push",
              icon: Icon(MdiIcons.sourceBranchPlus),
            ),
            CQPopupMenuDivider(),
            CQPopupMenuItemSimple(
              label: "New Branch",
              icon: Icon(MdiIcons.sourceBranchPlus),
            ),
            CQPopupMenuItemSimple(label: "Checkout Tag or Revision"),
          ],
        );
      },
      child: Container(
        key: branchMenuKey,
        child: Row(
          children: [
            Icon(
              MdiIcons.sourceBranch,
              color: widget.project.theme.baseStyle.color,
              size: 14,
              weight: 1,
            ),
            Text(
              "main",
              style: TextStyle(
                color: widget.project.theme.baseStyle.color,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
