import 'dart:ffi' as ffi;
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'tree_sitter_bindings.dart';

class TreeSitter {
  static final TreeSitterBindings _bindings = TreeSitterBindings(
    _loadLibrary(),
  );

  const TreeSitter();

  static ffi.DynamicLibrary _loadLibrary() {
    if (Platform.isMacOS || Platform.isIOS) {
      return ffi.DynamicLibrary.process();
    } else if (Platform.isWindows) {
      return ffi.DynamicLibrary.open('tree-sitter.dll');
    } else if (Platform.isLinux) {
      return ffi.DynamicLibrary.open('libtree-sitter.so');
    } else if (Platform.isAndroid) {
      return ffi.DynamicLibrary.open('libtree_sitter.so');
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}

class TreeSitterLanguage {
  final String languageName;
  late final Pointer<TSLanguage> _languagePtr;

  TreeSitterLanguage(this.languageName);

  dynamic getLanguagePtr() {
    return _languagePtr.address;
  }

  void dispose() {
    if (_languagePtr.address != 0) {
      TreeSitter._bindings.ts_language_delete(_languagePtr);
      _languagePtr = Pointer<TSLanguage>.fromAddress(0);
    }
  }
}

class Parser {
  late final Pointer<TSParser> parser;

  TreeSitterLanguage? language;

  Parser() {
    final parserPtr = TreeSitter._bindings.ts_parser_new();
    if (parserPtr.address == 0) {
      throw Exception('Failed to create Tree-sitter parser');
    }
    parser = parserPtr;
  }

  void dispose() {
    if (parser.address != 0) {
      TreeSitter._bindings.ts_parser_delete(parser);
      parser = Pointer<TSParser>.fromAddress(0);
    }
  }

  bool setLanguage(TreeSitterLanguage language) {
    final result = TreeSitter._bindings.ts_parser_set_language(
      parser,
      Pointer.fromAddress(language.getLanguagePtr()).cast<TSLanguage>(),
    );
    if (result == false) {
      throw Exception('Failed to set language for Tree-sitter parser');
    }
    this.language = language;
    return result;
  }

  TreeSitterLanguage? currentLanguage() {
    return language;
  }

  setIncludedRanges(List<Range> ranges) {
    final ffi.Pointer<TSRange> rangePtr = calloc<TSRange>(ranges.length);
    for (int i = 0; i < ranges.length; i++) {
      rangePtr[i] = ranges[i].toTSRange();
    }
    TreeSitter._bindings.ts_parser_set_included_ranges(
      parser,
      rangePtr,
      ranges.length,
    );
    calloc.free(rangePtr);
  }

  List<Range> currentRanges() {
    var count = malloc<ffi.Uint32>();
    final tsRanges = TreeSitter._bindings.ts_parser_included_ranges(
      parser,
      count,
    );
    if (count.value == 0) {
      return [];
    }

    final ranges = <Range>[];
    for (int i = 0; i < count.value; i++) {
      final tsRange = tsRanges[i];
      ranges.add(
        Range(
          startRow: tsRange.start_point.row,
          startColumn: tsRange.start_point.column,
          endRow: tsRange.end_point.row,
          endColumn: tsRange.end_point.column,
        ),
      );
    }

    calloc.free(count);
    return ranges;
  }

  void setTimeout(int timeout) {
    TreeSitter._bindings.ts_parser_set_timeout_micros(parser, timeout);
  }

  int getTimeout() {
    final timeout = TreeSitter._bindings.ts_parser_timeout_micros(parser);
    return timeout;
  }

  Tree parseString(String sourceCode, [Tree? oldTree]) {
    final sourcePtr = sourceCode.toNativeUtf8();
    final sourceLength = sourcePtr.length;

    Pointer<TSTree> treePtr;
    treePtr = TreeSitter._bindings.ts_parser_parse_string(
      parser,
      (oldTree != null) ? oldTree.tree : nullptr,
      sourcePtr.cast(),
      sourceLength,
    );

    malloc.free(sourcePtr);
    return Tree(treePtr);
  }
}

class Tree {
  late final Pointer<TSTree> tree;

  Tree(Pointer<TSTree> treePtr) {
    if (treePtr.address == 0) {
      throw Exception('Failed to create Tree-sitter tree');
    }
    tree = treePtr;
  }
  Tree copy() {
    final copied = TreeSitter._bindings.ts_tree_copy(tree);
    return Tree(copied);
  }

  void dispose() {
    if (tree.address != 0) {
      TreeSitter._bindings.ts_tree_delete(tree);
      tree = Pointer<TSTree>.fromAddress(0);
    }
  }

  Node rootNode() {
    final node = TreeSitter._bindings.ts_tree_root_node(tree);
    return Node(node);
  }
}

class Node {
  final TSNode node;

  Node(this.node);

  String get type {
    return TreeSitter._bindings.ts_node_type(node).cast<Utf8>().toDartString();
  }

  int get startByte => TreeSitter._bindings.ts_node_start_byte(node);
  int get endByte => TreeSitter._bindings.ts_node_end_byte(node);

  TSPoint get startPoint => TreeSitter._bindings.ts_node_start_point(node);
  TSPoint get endPoint => TreeSitter._bindings.ts_node_end_point(node);

  bool get isNamed => TreeSitter._bindings.ts_node_is_named(node);
  bool get isNull => TreeSitter._bindings.ts_node_is_null(node);

  int get childCount => TreeSitter._bindings.ts_node_child_count(node);
  int get namedChildCount =>
      TreeSitter._bindings.ts_node_named_child_count(node);

  Node child(int i) {
    final c = TreeSitter._bindings.ts_node_child(node, i);
    return Node(c);
  }

  Node namedChild(int i) {
    final c = TreeSitter._bindings.ts_node_named_child(node, i);
    return Node(c);
  }

  Node? parent() {
    final p = TreeSitter._bindings.ts_node_parent(node);
    return Node(p);
  }

  Node? nextSibling() {
    final sib = TreeSitter._bindings.ts_node_next_sibling(node);
    return Node(sib);
  }

  Node? prevSibling() {
    final sib = TreeSitter._bindings.ts_node_prev_sibling(node);
    return Node(sib);
  }
}

class Range {
  final int startRow;
  final int startColumn;
  final int endRow;
  final int endColumn;

  Range({
    required this.startRow,
    required this.startColumn,
    required this.endRow,
    required this.endColumn,
  });

  TSRange toTSRange() {
    var range = malloc<TSRange>();
    var start = malloc<TSPoint>();
    var end = malloc<TSPoint>();

    start.ref.row = startRow;
    start.ref.column = startColumn;
    end.ref.row = endRow;
    end.ref.column = endColumn;

    range.ref.start_point = start.ref;
    range.ref.end_point = end.ref;

    var tsRange = range.ref;

    return tsRange;
  }
}
