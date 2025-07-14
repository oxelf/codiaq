import 'package:codiaq_editor/codiaq_editor.dart';
import 'package:codiaq_editor/src/fs/fs_provider.dart';
import 'package:codiaq_editor/src/icons/seti.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FileExplorerCache {
  final FSProvider fsProvider;

  /// Map of expanded/collapsed states for directories
  final Map<String, bool> dirToggleState = {};

  FileExplorerCache(this.fsProvider);
}

class FileExplorer extends StatefulWidget {
  final FileExplorerCache cache;
  final String rootPath;
  final EditorTheme theme;
  final Function(String path)? onPathSelected;

  const FileExplorer({
    super.key,
    required this.cache,
    required this.rootPath,
    required this.theme,
    this.onPathSelected,
  });

  @override
  State<FileExplorer> createState() => _FileExplorerState();
}

class _FileExplorerState extends State<FileExplorer> {
  String? _selectedPath;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _selectedPath = widget.rootPath;
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      autofocus: true,
      focusNode: _focusNode,
      onKeyEvent: _handleKeyPress,
      child: Scrollbar(
        child: FutureBuilder<List<FsEntity>>(
          future: widget.cache.fsProvider.list(widget.rootPath),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(strokeWidth: 1.5),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.red),
                ),
              );
            }

            final children = _sorted(snapshot.data!);
            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              children:
                  children.map((e) {
                    return _buildEntry(e, 0);
                  }).toList(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEntry(FsEntity entity, int indentLevel) {
    final isDir = entity is FsDirectory;
    final isExpanded = widget.cache.dirToggleState[entity.path] ?? false;

    final indent = SizedBox(width: indentLevel * 12.0);

    final isSelected = _selectedPath == entity.path;
    final style = TextStyle(
      fontSize: 13,
      color: isSelected ? Colors.white : Colors.grey.shade300,
      fontWeight: isDir ? FontWeight.w500 : FontWeight.normal,
    );

    final background = isSelected ? widget.theme.selectionColor : null;

    final icon =
        isDir
            ? Icon(
              isExpanded
                  ? Icons.keyboard_arrow_down
                  : Icons.keyboard_arrow_right,
              size: 16,
              color: widget.theme.iconTheme.color,
            )
            : SizedBox(width: 16, child: getSetiIcon(entity.path));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _onTapEntity(entity),
          child:
              background != null
                  ? Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: _entryRow(indent, icon, entity, style),
                  )
                  : _entryRow(indent, icon, entity, style),
        ),
        if (isDir && isExpanded) _buildSubtree(entity.path, indentLevel + 1),
      ],
    );
  }

  Widget _entryRow(
    Widget indent,
    Widget icon,
    FsEntity entity,
    TextStyle style,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: Row(
        children: [
          indent,
          icon,
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              _basename(entity.path),
              style: style,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  List<FsEntity> _sorted(List<FsEntity> entities) {
    final folders = entities.whereType<FsDirectory>().toList();
    final files = entities.where((e) => e is! FsDirectory).toList();

    folders.sort(
      (a, b) => _basename(
        a.path,
      ).toLowerCase().compareTo(_basename(b.path).toLowerCase()),
    );
    files.sort(
      (a, b) => _basename(
        a.path,
      ).toLowerCase().compareTo(_basename(b.path).toLowerCase()),
    );

    return [...folders, ...files];
  }

  Widget _buildSubtree(String path, int indentLevel) {
    return FutureBuilder<List<FsEntity>>(
      future: widget.cache.fsProvider.list(path),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        var children = snapshot.data!;
        children = _sorted(children);
        return Column(
          children: children.map((e) => _buildEntry(e, indentLevel)).toList(),
        );
      },
    );
  }

  void _onTapEntity(FsEntity entity) {
    setState(() {
      _selectedPath = entity.path;

      if (entity is FsDirectory) {
        final prev = widget.cache.dirToggleState[entity.path] ?? false;
        widget.cache.dirToggleState[entity.path] = !prev;
      } else {
        widget.onPathSelected?.call(entity.path);
      }
    });
  }

  void _handleKeyPress(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    if (_selectedPath == null) return;

    switch (event.logicalKey.keyId) {
      case LogicalKeyboardKey.arrowDown:
        _moveSelection(offset: 1);
        break;
      case LogicalKeyboardKey.arrowUp:
        _moveSelection(offset: -1);
        break;
      case LogicalKeyboardKey.arrowRight:
        _expandCurrent();
        break;
      case LogicalKeyboardKey.arrowLeft:
        _collapseCurrent();
        break;
      case LogicalKeyboardKey.enter:
        _toggleExpandCollapse();
        break;
    }
  }

  void _moveSelection({required int offset}) async {
    final flatList = await _buildFlatPathList();
    final currentIndex = flatList.indexOf(_selectedPath!);
    final nextIndex = (currentIndex + offset).clamp(0, flatList.length - 1);
    setState(() {
      _selectedPath = flatList[nextIndex];
    });
  }

  Future<List<String>> _buildFlatPathList() async {
    final result = <String>[];

    Future<void> walk(String path) async {
      final entity = await widget.cache.fsProvider.getEntity(path);
      result.add(path);

      if (entity is FsDirectory &&
          (widget.cache.dirToggleState[path] ?? false)) {
        final children = await widget.cache.fsProvider.list(path);
        for (final child in children) {
          await walk(child.path);
        }
      }
    }

    await walk(widget.rootPath);
    return result;
  }

  void _expandCurrent() {
    if (_selectedPath == null) return;
    final isExpanded = widget.cache.dirToggleState[_selectedPath!] ?? false;
    setState(() {
      widget.cache.dirToggleState[_selectedPath!] = true;
    });
  }

  void _collapseCurrent() {
    if (_selectedPath == null) return;
    setState(() {
      widget.cache.dirToggleState[_selectedPath!] = false;
    });
  }

  void _toggleExpandCollapse() {
    final current = _selectedPath;
    if (current == null) return;
    final state = widget.cache.dirToggleState[current] ?? false;
    setState(() {
      widget.cache.dirToggleState[current] = !state;
    });
  }

  String _basename(String path) {
    return path.split(RegExp(r'[\\/]')).last;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
