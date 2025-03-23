typedef ItemDisposeCallback = void Function();

class Item<T> {
  Item(this.data, this.metaData);

  final T data;
  final ItemMetaData metaData;

  void dispose() {
    for (final callback in metaData.disposeCallbacks) {
      callback();
    }
  }
}

class ItemMetaData {
  ItemMetaData({
    List<ItemDisposeCallback>? disposeCallbacks,
    List<Object>? disposableObjects,
  })  : disposeCallbacks = disposeCallbacks ?? [],
        disposableObjects = disposableObjects ?? [];

  final List<ItemDisposeCallback> disposeCallbacks;

  /// A list of objects that are registered for disposal in [disposeCallbacks].
  final List<Object> disposableObjects;

  void safeAddDisposeCallback(ItemDisposeCallback callback) {
    if (disposeCallbacks.contains(callback)) return;
    disposeCallbacks.add(callback);
  }

  T safeAddDisposableObject<T extends Object>(
    T object, [
    void Function(T)? dispose,
  ]) {
    if (disposableObjects.contains(object)) return object;
    disposableObjects.add(object);

    bool disposing = false;

    // dispose object when the item is being removed from the store
    disposeCallbacks.add(
      () {
        if (disposing) return;
        disposing = true;

        dispose == null ? (object as dynamic).dispose() : dispose(object);
      },
    );

    return object;
  }

  T safeBindTo<T extends Object>(
    T object, {
    void Function(T)? dispose,
    void Function(void Function() disposeItemFromStore)? onObjectDispose,
    required void Function() disposeFromStore,
  }) {
    if (disposableObjects.contains(object)) return object;
    disposableObjects.add(object);

    bool disposing = false;

    // dispose object when the item is being removed from the store
    disposeCallbacks.add(() {
      if (disposing) return;
      disposing = true;

      dispose == null ? (object as dynamic).dispose() : dispose(object);
    });

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
}
