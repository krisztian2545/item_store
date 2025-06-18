import 'dart:collection';

typedef ItemDisposeCallback = void Function();

class Item<T> {
  Item(this.data, this.metaData);

  final T data;
  final ItemMetaData metaData;

  void dispose() {
    metaData._dispose();
  }
}

typedef DisposableObjectRecord<T extends Object> = (T, void Function(T));

class ItemMetaData {
  ItemMetaData({
    List<ItemDisposeCallback>? disposeCallbacks,
    List<DisposableObjectRecord>? disposableObjects,
  })  : _disposeCallbacks = [],
        _disposableObjects = {},
        _disposed = false {
    if (disposableObjects != null) {
      for (final args in disposableObjects) {
        addDisposableObject(args.$1, args.$2);
      }
    }
    if (disposeCallbacks != null) {
      for (final callback in disposeCallbacks) {
        addDisposeCallback(callback);
      }
    }
  }

  final List<ItemDisposeCallback> _disposeCallbacks;
  UnmodifiableListView<ItemDisposeCallback> get disposeCallbacks =>
      UnmodifiableListView(_disposeCallbacks);

  /// A list of objects that are registered for disposal in [disposeCallbacks].
  final Map<Object, ItemDisposeCallback> _disposableObjects;
  UnmodifiableListView<Object> get disposableObjects =>
      UnmodifiableListView(_disposableObjects.keys);

  bool _disposed;
  bool get disposed => _disposed;

  // ------------------ Dispose Callback -----------------

  void addDisposeCallback(ItemDisposeCallback callback) {
    assert(!_disposed);
    if (_disposed || _disposeCallbacks.contains(callback)) return;
    _disposeCallbacks.add(callback);
  }

  void removeDisposeCallback(ItemDisposeCallback callback) {
    assert(!_disposed);
    if (_disposed) return;
    _disposeCallbacks.remove(callback);
  }

  // ------------------ Disposable Object -----------------

  T addDisposableObject<T extends Object>(
    T object, [
    void Function(T)? dispose,
  ]) {
    assert(!_disposed);
    if (_disposed || _disposableObjects.keys.contains(object)) return object;

    bool disposing = false;
    void actualDisposeCallback() {
      if (disposing) return;
      disposing = true;

      dispose == null ? (object as dynamic).dispose() : dispose(object);
    }

    _disposableObjects[object] = actualDisposeCallback;

    // dispose object when the item is being removed from the store
    _disposeCallbacks.add(actualDisposeCallback);

    return object;
  }

  void removeDisposableObject<T extends Object>(T object) {
    assert(!_disposed);
    if (_disposed) return;
    final removeCallback = _disposableObjects.remove(object);
    if (removeCallback != null) {
      removeDisposeCallback(removeCallback);
    }
  }

  // ------------------ Two-way Dispose Binding -----------------

  T bindTo<T extends Object>(
    T object, {
    void Function(T)? dispose,
    void Function(void Function() disposeItemFromStore)? onObjectDispose,
    required void Function() disposeFromStore,
  }) {
    assert(!_disposed);
    if (_disposed || _disposableObjects.keys.contains(object)) return object;

    bool disposing = false;
    void actualDisposeCallback() {
      if (disposing) return;
      disposing = true;

      dispose == null ? (object as dynamic).dispose() : dispose(object);
    }

    _disposableObjects[object] = actualDisposeCallback;

    // dispose object when the item is being removed from the store
    _disposeCallbacks.add(actualDisposeCallback);

    void safeDisposeSelf() {
      if (disposing) return;
      disposing = true;

      disposeFromStore();
    }

    if (onObjectDispose == null) {
      (object as dynamic).onDispose(safeDisposeSelf);
    } else {
      onObjectDispose(safeDisposeSelf);
    }

    return object;
  }

  // --------------------------------------------------------------

  void _dispose() {
    assert(!_disposed);
    if (_disposed) return;
    _disposed = true;
    for (final callback in _disposeCallbacks) {
      callback();
    }
    _disposeCallbacks.clear();
    _disposableObjects.clear();
  }
}
