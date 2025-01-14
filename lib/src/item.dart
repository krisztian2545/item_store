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
    this.dependecies,
  })  : disposeCallbacks = disposeCallbacks ?? [],
        disposableObjects = disposableObjects ?? [];

  final List<ItemDisposeCallback> disposeCallbacks;

  /// A list of objects that are registered for disposal in [disposeCallbacks].
  final List<Object> disposableObjects;

  final List<Object>? dependecies;
}
