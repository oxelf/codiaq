import 'package:flutter/foundation.dart';

import '../buffer/buffer.dart';

class BufferListNotifier extends ChangeNotifier {
  final List<Buffer> _buffers = [];

  List<Buffer> get value => List.unmodifiable(_buffers);

  void add(Buffer buffer) {
    _buffers.add(buffer);
    notifyListeners();
  }

  void remove(Buffer buffer) {
    _buffers.remove(buffer);
    notifyListeners();
  }

  void removeWhere(bool Function(Buffer) test) {
    _buffers.removeWhere(test);
    notifyListeners();
  }

  void insert(int index, Buffer buffer) {
    _buffers.insert(index, buffer);
    notifyListeners();
  }

  void reorder(int oldIndex, int newIndex) {
    final buffer = _buffers.removeAt(oldIndex);
    _buffers.insert(newIndex, buffer);
    notifyListeners();
  }

  int indexWhere(bool Function(Buffer) test) => _buffers.indexWhere(test);
  void forEach(void Function(Buffer) action) {
    _buffers.forEach(action);
  }

  Buffer removeAt(int index) {
    if (index < 0 || index >= _buffers.length) {
      throw RangeError.index(index, _buffers, 'index');
    }
    var buf = _buffers.removeAt(index);
    notifyListeners();
    return buf;
  }

  List<Buffer> get buffers => List.unmodifiable(_buffers);

  int indexOf(Buffer buffer) => _buffers.indexOf(buffer);
  Buffer firstWhere(bool Function(Buffer) test, {Buffer Function()? orElse}) =>
      _buffers.firstWhere(
        test,
        orElse: orElse ?? () => throw StateError('No matching buffer found'),
      );
  bool any(bool Function(Buffer) test) => _buffers.any(test);
  bool get isEmpty => _buffers.isEmpty;
  bool get isNotEmpty => _buffers.isNotEmpty;
  Buffer operator [](int index) => _buffers[index];
  int get length => _buffers.length;
}
