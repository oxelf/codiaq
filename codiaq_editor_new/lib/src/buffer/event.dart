enum BufferEventType {
  modified,
  inserted,
  deleted,
  lspAttach,
  lspDetach,
  diagnostic,
  highlight,
  viewportChanged,
  hover,
  popupInserted,
  popupRemoved,
  undo,
  redo,
  fileTypeChanged,
  cursor,
  selection,
  breakpoint,
  gutter,
}

class BufferEvent {
  final int type;
  final Map<String, dynamic>? payload;

  BufferEvent(this.type, [this.payload]);
}

typedef BufferListener = void Function(BufferEvent event);

class BufferEvents {
  final List<BufferListener> _listeners = [];

  void addListener(BufferListener listener) {
    _listeners.add(listener);
  }

  void removeListener(BufferListener listener) {
    _listeners.remove(listener);
  }

  void emit(int type, [Map<String, dynamic>? payload]) {
    final event = BufferEvent(type, payload);
    for (var listener in _listeners) {
      listener(event);
    }
  }
}
