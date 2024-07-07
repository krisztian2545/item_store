typedef ItemDisposeCallback = void Function();

typedef ItemFactory<T> = T Function(Ref);

class ItemWithMetaData<T> {
  ItemWithMetaData(this.data, this.metaData);
  final T data;
  final ItemMetaData metaData;
}

class ItemMetaData {
  List<ItemDisposeCallback> disposeCallbacks = [];
}

typedef ItemCacheMap = Map<Object, ItemWithMetaData>;

class ItemStore {
  ItemStore() : _cache = {};

  ItemStore.fromMap(ItemCacheMap map) : _cache = map;

  final ItemCacheMap _cache;

  /// Don't use this unless you really have to.
  ItemCacheMap get cache => _cache;

  /// Helper function to determine your global key.
  ///
  /// {@template global_key_from}
  /// The global key is determined by the following steps:
  ///   - if [globalKey] is not null, then only it will be used as the global key
  ///     (in that case the [tag] is ignored and [itemFactory] is only used
  ///     to create the object),
  ///   - else if [tag] is not null, then it is combined into a record with
  ///     [itemFactory]. Useful if you want to store multiple objects with
  ///     the same object.
  ///   - else [itemFactory] on it's own is used as the global key.
  /// {@endtemplate}
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
  /// {@macro global_key_from}
  T create<T>(ItemFactory<T> itemFactory, {Object? globalKey, Object? tag}) {
    final key = globalKeyFrom(
      globalKey: globalKey,
      itemFactory: itemFactory,
      tag: tag,
    );

    final ref = Ref(store: this, itemKey: key);
    final result = itemFactory(ref);

    // dispose the local store of an item on its disposal
    ref.onDispose(() => ref.local.dispose());

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
    final item = _cache[globalKey];
    if (item == null) return;

    for (final dispose in item.metaData.disposeCallbacks) {
      dispose();
    }

    _cache.remove(globalKey);
  }

  /// Calls [disposeItem] for each key in [globalKeys].
  void disposeItems(List<Object> globalKeys) => globalKeys.forEach(disposeItem);

  bool get isEmpty => _cache.isEmpty;

  /// Disposes items and clears cache.
  void dispose() {
    disposeItems(_cache.keys.toList());
    _cache.clear();
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
  final ItemStore local = ItemStore();

  final Object itemKey;

  final ItemMetaData _itemMetaData = ItemMetaData();

  T call<T>(ItemFactory<T> itemFactory, {Object? globalKey, Object? tag}) =>
      _store.get<T>(itemFactory, globalKey: globalKey, tag: tag);

  T create<T>(ItemFactory<T> itemFactory, {Object? globalKey, Object? tag}) {
    return _store.create(itemFactory, globalKey: globalKey, tag: tag);
  }

  T read<T>(Object globalKey) => _store.read(globalKey);

  void disposeSelf() => _store.disposeItem(itemKey);

  /// Adds [callback] to the list of dispose callbacks.
  void onDispose(ItemDisposeCallback callback) {
    _itemMetaData.disposeCallbacks.add(callback);
  }

  void removeDisposeCallback(ItemDisposeCallback callback) {
    _itemMetaData.disposeCallbacks.remove(callback);
  }
}

extension RefUtilsX on Ref {
  /// Calls the provided object's dispose function on [onDispose].
  /// [disposable] must have a void dispose() function.
  T registerDisposable<T extends Object>(T disposable,
      {bool assertCompatibility = true}) {
    void bind(o) {
      // dispose object when being removed from the store
      onDispose(o.dispose);
    }

    if (assertCompatibility) {
      bind(disposable);
    } else {
      try {
        bind(disposable);
      } catch (e) {
        // disposable doesn't have a void dispose() function.
      }
    }

    return disposable;
  }

  /// Alias for [registerDisposable].
  T d<T extends Object>(T disposable) => registerDisposable(disposable);

  /// Bind the given [disposable] object to this ref, meaning if any of them gets disposed,
  /// both of them will be disposed.
  ///
  /// [disposable] must have:
  /// - a void dispose() function,
  /// - a void onDispose(void Function()) function.
  ///
  /// If [assertCompatibility] is false, no error will be thrown when
  /// [disposable] doesn't have one or all of the required functions.
  ///
  /// See also:
  /// - [registerDisposable] for one way binding,
  /// - [DisposableMixin] to add the required functions to your class.
  T bindToDisposable<T>(T disposable, {bool assertCompatibility = true}) {
    void bind(o) {
      // dispose object when being removed from the store
      onDispose(o.dispose);

      // dispose item from the store, when object gets disposed
      o.onDispose(disposeSelf);
    }

    if (assertCompatibility) {
      bind(disposable);
    } else {
      try {
        bind(disposable);
      } catch (e) {
        // disposable doesn't have a void dispose() function
        // or doesn't accept an onDispose callback.
      }
    }

    return disposable;
  }
}

/// Creates an item factory function which calls [RefUtilsX.bindToDisposable] on
/// the object returned by [objectFactory].
T Function(Ref) dof<T extends Object>(T Function(Ref) objectFactory) =>
    (ref) => ref.bindToDisposable(objectFactory(ref));
