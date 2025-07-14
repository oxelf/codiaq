import 'package:flutter/material.dart' show ValueNotifier;
import 'package:flutter/services.dart' show LogicalKeyboardKey;

import 'buffer.dart';
import 'types.dart';

class SearchManager {
  final Buffer buffer;
  ValueNotifier<bool> isActive = ValueNotifier<bool>(false);
  ValueNotifier<bool> regexSearch = ValueNotifier<bool>(false);
  ValueNotifier<bool> matchCase = ValueNotifier<bool>(false);
  ValueNotifier<int> matchCount = ValueNotifier<int>(0);

  SearchManager(this.buffer) {
    //buffer.inputHandler.registerHandler((event, buffer) {
    //  if (event.key == LogicalKeyboardKey.keyF &&
    //      (event.modifiers.ctrl || event.modifiers.meta)) {
    //    toggleSearch();
    //    return true;
    //  }
    //  return false;
    //});
  }

  toggleSearch() {
    isActive.value = !(isActive.value);
  }

  EditorTextRange rangeFromIndices(String text, int start, int end) {
    int startLine = 0;
    int startColumn = 0;
    int endLine = 0;
    int endColumn = 0;

    while (start >= 0 && start < text.length) {
      if (text[start] == '\n') {
        startLine++;
        startColumn = 0;
      } else {
        startColumn++;
      }
      start--;
    }

    while (end >= 0 && end < text.length) {
      if (text[end] == '\n') {
        endLine++;
        endColumn = 0;
      } else {
        endColumn++;
      }
      end--;
    }
    return EditorTextRange(
      start: EditorTextPosition(startLine, startColumn),
      end: EditorTextPosition(endLine, endColumn),
    );
  }

  void search(String query) {
    List<EditorTextRange> matches = [];

    if (query.isEmpty) {
      matches = [];
      return;
    }

    String content = buffer.lines.getText();
    String searchContent = matchCase.value ? content : content.toLowerCase();
    String searchQuery = matchCase.value ? query : query.toLowerCase();

    if (regexSearch.value) {
      var regex = RegExp(
        searchQuery,
        caseSensitive: matchCase.value,
        multiLine: true,
      );
      Iterable<RegExpMatch> foundMatches = regex.allMatches(searchContent);
      for (var match in foundMatches) {
        matches.add(rangeFromIndices(match.input, match.start, match.end));
      }
    } else {
      int index = searchContent.indexOf(searchQuery);
      while (index != -1) {
        matches.add(
          rangeFromIndices(searchContent, index, index + searchQuery.length),
        );
        index = searchContent.indexOf(searchQuery, index + searchQuery.length);
      }
    }

    print('Found ${matches.length} matches for "$query", matches: $matches');
  }
}
