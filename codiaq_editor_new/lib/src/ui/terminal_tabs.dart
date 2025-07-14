import 'dart:io';

import 'package:codiaq_editor/src/executor/shell_manager.dart';
import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart';

import '../executor/shell_entry.dart';

class TerminalTabBarWidget extends StatefulWidget {
  final ShellManager shellManager;

  const TerminalTabBarWidget({super.key, required this.shellManager});

  @override
  State<TerminalTabBarWidget> createState() => _TerminalTabBarWidgetState();
}

class _TerminalTabBarWidgetState extends State<TerminalTabBarWidget> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.shellManager.addListener(_onShellsChanged);
  }

  @override
  void dispose() {
    widget.shellManager.removeListener(_onShellsChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onShellsChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final shells = widget.shellManager.shells;
    final activeId = widget.shellManager.activeShell?.id;

    return Container(
      height: 36,
      decoration: const BoxDecoration(
        color: Color(0xFF2B2B2B),
        border: Border(bottom: BorderSide(color: Color(0xFF4E4E4E))),
      ),
      child: Row(
        children: [
          // Scrollable tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            child: Row(
              children: [
                for (final shell in shells)
                  _buildTab(shell, isActive: shell.id == activeId),
              ],
            ),
          ),
          // Fixed '+' button
          Container(
            width: 36,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF2B2B2B),
              border: Border(left: BorderSide(color: Color(0xFF4E4E4E))),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              padding: EdgeInsets.zero,
              onPressed: () => widget.shellManager.newShell(),
              tooltip: "New Terminal",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(ShellEntry shell, {required bool isActive}) {
    return GestureDetector(
      onTap: () => widget.shellManager.setActiveShell(shell.id),
      onSecondaryTapDown: (_) => _showRenameDialog(shell),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        height: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF3C3F41) : const Color(0xFF2B2B2B),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              shell.name,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[400],
              ),
            ),
            const SizedBox(width: 8),
            if (widget.shellManager.shells.length > 1)
              GestureDetector(
                onTap: () => widget.shellManager.closeShell(shell.id),
                child: const Icon(Icons.close, size: 16, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRenameDialog(ShellEntry shell) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: shell.name);
        return AlertDialog(
          title: const Text("Rename Terminal"),
          content: TextField(controller: controller),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text("Rename"),
            ),
          ],
        );
      },
    );
    if (newName != null && newName.trim().isNotEmpty) {
      widget.shellManager.renameShell(shell.id, newName.trim());
    }
  }
}

class CurrentTerminalWidget extends StatefulWidget {
  final ShellManager shellManager;
  const CurrentTerminalWidget({super.key, required this.shellManager});

  @override
  State<CurrentTerminalWidget> createState() => _CurrentTerminalWidgetState();
}

class _CurrentTerminalWidgetState extends State<CurrentTerminalWidget> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.shellManager,
      builder: (context, _) {
        return (widget.shellManager.activeShell != null)
            ? Container(
              decoration: BoxDecoration(),
              clipBehavior: Clip.hardEdge,
              child: TerminalView(
                widget.shellManager.activeShell!.shell.terminal,
                hardwareKeyboardOnly: (!Platform.isIOS && !Platform.isAndroid),
              ),
            )
            : const Center(child: Text("No active terminal"));
      },
    );
  }
}
