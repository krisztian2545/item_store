import 'item.dart';
import 'ref.dart';

typedef ItemFactory<T> = T Function(Ref);

typedef ItemCacheMap = Map<Object, Item>;

typedef OverridesMap = Map<ItemFactory, ItemFactory>;
typedef OverrideRecord<T> = (ItemFactory<T>, ItemFactory<T>);
typedef OverridesList = List<OverrideRecord>;

// class FactoryOverride<T> {
//   FactoryOverride(this.from, this.to);
//   final ItemFactory<T> from;
//   final ItemFactory<T> to;
// }

asd() {
  int counter(Ref ref) => 5;
  String label(Ref ref) => '0';

  final store = ItemStore(overrides: [
    (counter, label),
  ]);

  store.override(counter, label);
}

class ItemStore {
  ItemStore({OverridesList? overrides}) : _cache = {} {
    _initOverrides(overrides);
  }

  ItemStore.from(ItemCacheMap map, {OverridesList? overrides}) : _cache = map {
    _initOverrides(overrides);
  }

  static const _assertFactoryOverrideReturnTypeMessage =
      "Can't override an item factory with different return type!";

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

  void _initOverrides(OverridesList? overrides) {
    if (overrides?.isNotEmpty ?? false) {
      _overrides.addEntries(overrides!.map((e) {
        assert(
          e.$1.runtimeType == e.$2.runtimeType,
          _assertFactoryOverrideReturnTypeMessage,
        );
        return MapEntry(e.$1, e.$2);
      }));
    }
  }

  final ItemCacheMap _cache;

  /// Please don't use this unless you really have to.
  ItemCacheMap get cache => _cache;

  final OverridesMap _overrides = {};

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

    final ref = Ref(store: this, itemKey: key, itemTag: tag);
    final result = _overrides[itemFactory]?.call(ref) ?? itemFactory(ref);

    // dispose the local store of an item on its disposal
    ref.onDispose(() => ref.local.dispose());

    _cache[key] = Item<T>(result, ref.itemMetaData);

    return result;
  }

  /// Reads the cached value stored with [globalKey].
  /// You can calculate your global key with [globalKeyFrom].
  T? read<T>(Object globalKey) {
    return (_cache[globalKey] as Item<T>?)?.data;
  }

  /// Disposes the item and then removes it from the cache.
  void disposeItem(Object globalKey) {
    final item = _cache[globalKey];
    if (item == null) return;

    item.dispose();

    _cache.remove(globalKey);
  }

  /// Overrides the [from] factory with the [to] factory. So when creating
  /// an item (whether trough [create] or [get]), the [to] factory will be
  /// used instead of the original one, even if both an itemFactory and a
  /// global key is given.
  ///
  /// The overriding factory must have the same return type as the original one.
  ///
  /// If an item is already created with the original factory, it won't be affected
  /// by this override.
  ///
  /// This overrides an item factory (not a value of a key). If you just want
  /// to override the value of a key, consider using [create] instead.
  void override<T>(ItemFactory<T> from, ItemFactory<T> to) {
    assert(
      from.runtimeType == to.runtimeType,
      _assertFactoryOverrideReturnTypeMessage,
    );
    _overrides[from] = to;
  }

  void removeOverrideFrom(ItemFactory factory) {
    _overrides.remove(factory);
  }

  /// Calls [disposeItem] for each key in [globalKeys].
  void disposeItems(Iterable<Object> globalKeys) =>
      globalKeys.forEach(disposeItem);

  bool get isEmpty => _cache.isEmpty;

  /// Disposes items and clears cache.
  void dispose() {
    disposeItems(_cache.keys);
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

extension type LocalItemStore(ItemStore _store) implements ItemStore {
  T call<T>(ItemFactory<T> itemFactory, {Object? globalKey, Object? tag}) =>
      _store.get<T>(itemFactory, globalKey: globalKey, tag: tag);
}
