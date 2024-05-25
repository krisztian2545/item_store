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

typedef ItemCacheMap = Map<Object, ItemWithMetaData>;

class ItemStore {
  ItemStore() : _cache = {};

  ItemStore.fromMap(ItemCacheMap map) : _cache = map;

  final ItemCacheMap _cache;

  /// Don't use this if you don't have to.
  ItemCacheMap get cache => _cache;

  /// Helper function to determine your global key.
  ///
  /// The global key is determined by the following steps:
  ///   - if [globalKey] is not null, then only it will be used as the global key
  ///     (in that case the [tag] is ignored and [itemFactory] is only used
  ///     to create the object),
  ///   - else if [tag] is not null, then it is combined into a record with
  ///     [itemFactory]. Useful if you want to store multiple objects with
  ///     the same object.
  ///   - else [itemFactory] on it's own is used as the global key.
  static Object globalKeyFrom<T>({
    Object? globalKey,
    ItemFactory<T>? itemFactory,
    Object? tag,
  }) {
    assert(
      itemFactory != null || globalKey != null,
      'At least one of itemFactory or globalKey must not be null',
    );

    if (globalKey != null) return globalKey;

    if (itemFactory != null) {
      return tag == null ? itemFactory : (itemFactory, tag);
    }

    throw Exception(
        'At least one of itemFactory or globalKey must not be null');
  }

  /// Creates an object by calling [itemFactory] and writes it into the cache
  /// with a global key, by which you can get it back later with [read].
  /// If there is an object cached with the same global key, then it will be
  /// overwritten.
  ///
  /// This global key is determined by the following steps:
  ///   - if [globalKey] is not null, then only it will be used as the global key
  ///     (in that case the [tag] is ignored and [itemFactory] is only used
  ///     to create the object),
  ///   - else if [tag] is not null, then it is combined into a record with
  ///     [itemFactory]. Useful if you want to store multiple objects tagged
  ///     with the same object.
  ///   - else [itemFactory] on it's own is used as the global key.
  T create<T>(ItemFactory<T> itemFactory, {Object? globalKey, Object? tag}) {
    final key = globalKeyFrom(
      globalKey: globalKey,
      itemFactory: itemFactory,
      tag: tag,
    );

    final ref = Ref(store: this, itemKey: key);
    final result = itemFactory(ref);
    _cache[key] = ItemWithMetaData<T>(result, ref._itemMetaData);

    return result;
  }

  /// Reads the cached value stored with [globalKey].
  /// You can calculate your global key with [globalKeyFrom].
  T? read<T>(Object globalKey) {
    return (_cache[globalKey] as ItemWithMetaData<T>?)?.data;
  }

  /// Disposes the item and then removes it from the cache.
  void disposeItem(Object globalKey) {
    _cache
      ..[globalKey]?.metaData.onDispose?.call(this)
      ..remove(globalKey);
  }

  /// Calls [disposeItem] for each key in [globalKeys].
  void disposeItems(List<Object> globalKeys) => globalKeys.forEach(disposeItem);

  bool get isEmpty => _cache.isEmpty;

  /// Disposes items and clears cache.
  void dispose() {
    _cache
      ..values.map((e) => e.metaData.onDispose).forEach((e) => e?.call(this))
      ..clear();
  }
}

extension ItemStoreUtilX on ItemStore {
  /// [create]s an item or [read]s it if it's already cached.
  T get<T>(ItemFactory<T> itemFactory, {Object? globalKey, Object? tag}) {
    final key = ItemStore.globalKeyFrom(
      globalKey: globalKey,
      itemFactory: itemFactory,
      tag: tag,
    );
    return read<T>(key) ?? create(itemFactory, globalKey: key);
  }
}

class Ref {
  Ref({
    required ItemStore store,
    required this.itemKey,
  }) : _store = store;

  final ItemStore _store;

  final Object itemKey;

  final List _disposables = [];

  final ItemMetaData _itemMetaData = ItemMetaData();

  T call<T>(ItemFactory<T> itemFactory, {Object? globalKey, Object? tag}) =>
      _store.get<T>(itemFactory, globalKey: globalKey, tag: tag);

  T create<T>(ItemFactory<T> itemFactory, {Object? globalKey, Object? tag}) {
    return _store.create(itemFactory, globalKey: globalKey, tag: tag);
  }

  T read<T>(Object globalKey) => _store.read(globalKey);

  ItemDisposeCallback _createDisposeCallback(ItemDisposeCallback? callback) {
    return (store) {
      callback?.call(store);
      for (final disposable in _disposables) {
        disposable.dispose();
      }
    };
  }

  void disposeSelf() => _store.disposeItem(itemKey);

  void onDispose(ItemDisposeCallback callback) {
    _itemMetaData.onDispose = _createDisposeCallback(callback);
  }

  /// Disposes the object on [onDispose].
  /// [disposable] must have a void dispose() function.
  T registerDisposable<T>(T disposable) {
    _disposables.add(disposable);
    _itemMetaData.onDispose = _createDisposeCallback(_itemMetaData.onDispose);
    return disposable;
  }
}

extension RefUtilsX on Ref {
  /// Alias for [registerDisposable].
  T d<T>(T disposable) => registerDisposable(disposable);
}
