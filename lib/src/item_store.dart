typedef ItemDisposeCallback = void Function(ItemStore);

typedef ItemFactory<T> = T Function(Ref);

class ItemWithMetaData<T> {
  ItemWithMetaData(this.data, this.metaData);
  final T data;
  final ItemMetaData metaData;
}

class ItemMetaData {
  ItemDisposeCallback? onDispose;
}

class ItemStore {
  final _cache = <Object, ItemWithMetaData>{};

  T create<T>(ItemFactory<T> itemFactory, {required Object key}) {
    final ref = Ref(store: this);
    final result = itemFactory(ref);
    _cache[key] = ItemWithMetaData<T>(result, ref._itemMetaData);

    return read<T>(key);
  }

  T read<T>(Object key) {
    return (_cache[key] as ItemWithMetaData<T>).data;
  }

  // T get<T>(ItemFactory<T> itemFactory) {
  //   if (!_cache.keys.contains(itemFactory)) {
  //     create(itemFactory, key: itemFactory);
  //   }

  //   return read<T>(itemFactory);
  // }

  /// Disposes the item and then removes it from the cache.
  void disposeItem(Object key) {
    _cache
      ..[key]?.metaData.onDispose?.call(this)
      ..remove(key);
  }

  bool get isEmpty => _cache.isEmpty;

  /// Disposes items and clears cache.
  void dispose() {
    _cache
      ..values.map((e) => e.metaData.onDispose).forEach((e) => e?.call(this))
      ..clear();
  }
}

extension ItemStoreClosureX on ItemStore {
  T get<T>(ItemFactory<T> itemFactory) {
    if (!_cache.keys.contains(itemFactory)) {
      create(itemFactory, key: itemFactory);
    }

    return read<T>(itemFactory);
  }
}

class Ref {
  Ref({required ItemStore store}) : _store = store;

  final ItemStore _store;

  final ItemMetaData _itemMetaData = ItemMetaData();

  T call<T>(ItemFactory<T> itemFactory) => _store.get<T>(itemFactory);

  T create<T>(ItemFactory<T> itemFactory, {required Object key}) {
    return _store.create(itemFactory, key: key);
  }

  T read<T>(Object key) => _store.read(key);

  void onDispose(void Function(ItemStore) callback) {
    _itemMetaData.onDispose = callback;
  }
}
