import 'package:codiaq_editor/codiaq_editor.dart';
import 'package:flutter/material.dart';

import 'package:codiaq_editor/codiaq_editor.dart';
import 'package:flutter/material.dart';

import '../buffer/search.dart';
import '../buffer/types.dart';

class SearchWidget extends StatefulWidget {
  final Buffer buffer;
  const SearchWidget({super.key, required this.buffer});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int currentIndex = 0;
  List<EditorTextRange> currentMatches = [];
  bool expanded = false;

  SearchManager get search => widget.buffer.search;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onQueryChanged);
    search.isActive.addListener(_onSearchActiveChanged);
    if (search.isActive.value) _focusNode.requestFocus();
  }

  void _onSearchActiveChanged() {
    if (search.isActive.value) {
      _focusNode.requestFocus();
    } else {
      _controller.clear();
    }
    setState(() {});
  }

  void _onQueryChanged() {
    final query = _controller.text;
    search.search(query);
    currentIndex = 0; // reset to first
    // TODO: fetch real matches if SearchManager exposes them
    // For now, just update match count
    search.matchCount.value = query.isEmpty ? 0 : 1; // dummy
  }

  void _nextMatch() {
    // You can enhance this when SearchManager provides actual match list
    setState(() {
      if (search.matchCount.value == 0) return;
      currentIndex = (currentIndex + 1) % search.matchCount.value;
    });
  }

  void _prevMatch() {
    setState(() {
      if (search.matchCount.value == 0) return;
      currentIndex =
          (currentIndex - 1 + search.matchCount.value) %
          search.matchCount.value;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    search.isActive.removeListener(_onSearchActiveChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!search.isActive.value) return const SizedBox.shrink();

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: widget.buffer.theme.backgroundColor,
        border: Border.all(color: widget.buffer.theme.dividerColor),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon((!expanded) ? Icons.chevron_right : Icons.expand_more),
            color: widget.buffer.theme.baseStyle.color,
            onPressed:
                () => setState(() {
                  expanded = !expanded;
                }),
            tooltip: 'Toggle search',
          ),
          Container(
            width: 2,
            color: widget.buffer.theme.dividerColor,
          ), // Divider

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.search,
              color: widget.buffer.theme.baseStyle.color,
            ),
          ),
          SizedBox(width: 8), // Spacing
          Flexible(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onTapOutside: (_) => _focusNode.unfocus(),
              cursorColor: widget.buffer.theme.cursorColor,
              style: widget.buffer.theme.baseStyle.copyWith(fontSize: 14),
              onEditingComplete: () {
                // Trigger search on enter
                search.search(_controller.text);
                _focusNode.unfocus();
              },
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Search',
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: search.matchCount,
            builder: (_, count, __) {
              final indexText = count == 0 ? '0' : '${currentIndex + 1}';
              return Text(
                '$indexText / $count',
                style: Theme.of(context).textTheme.bodySmall,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_up),
            onPressed: _prevMatch,
            tooltip: 'Previous match',
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed: _nextMatch,
            tooltip: 'Next match',
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => search.toggleSearch(),
            tooltip: 'Close search',
          ),
        ],
      ),
    );
  }
}
