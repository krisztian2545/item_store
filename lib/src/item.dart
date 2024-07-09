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
  ItemMetaData({this.disposeCallbacks = const []});

  final List<ItemDisposeCallback> disposeCallbacks;
}
