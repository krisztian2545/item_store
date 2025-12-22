import 'package:item_store/src/item_factory.dart';
import 'package:item_store/src/items_api.dart';
import 'package:item_store/src/utils.dart';
import 'package:meta/meta.dart';

import 'item.dart';
import 'ref.dart';

typedef ItemCacheMap = Map<Object, Item>;

typedef OverridesMap = Map<ItemFactory, ItemFactory>;
typedef OverrideRecord<T> = (ItemFactory<T>, ItemFactory<T>);
typedef OverridesList = List<OverrideRecord>;
typedef DefaultItemStoreType = SimpleItemStore;

abstract class ItemStore with ItemsApi {
  factory ItemStore({OverridesList? overrides}) => SimpleItemStore(overrides: overrides);

  static const defaultType = DefaultItemStoreType;

  static const _assertFactoryOverrideReturnTypeMessage =
      "Can't override an item factory with different return type!";

  /// Helper function to determine your global key.
  ///
  /// {@template global_key_from}
  /// The global key is determined by the following steps:
  ///   - if [args] is not null, then it is combined into a record with
  ///     [itemFactory].
  ///   - else [itemFactory] on it's own is used as the global key.
  /// {@endtemplate}
  static Object keyFrom<T>(ItemFactory<T>? itemFactory, Object? key) {
    assert(
      itemFactory != null || key != null,
      "You must provide one of either itemFactory or globalKey!",
    );

    if (key != null) {
      return key;
    }
    return itemFactory!;
  }

  /// Calculates the global key of a value.
  static Object valueKeyFrom(Type type, {Object? tag}) => tag == null ? type : (type, tag);

  ItemCacheMap get cache;

  bool get isEmpty;

  bool contains(Object key);

  OverridesMap get overrides;

  /// Disposes items and clears cache.
  void dispose();
}

/// The most basic implementation of [ItemStore].
class SimpleItemStore implements ItemStore {
  SimpleItemStore({OverridesList? overrides}) : _cache = {} {
    _initOverrides(overrides);
  }

  SimpleItemStore.from(ItemCacheMap map, {OverridesList? overrides}) : _cache = map {
    _initOverrides(overrides);
  }

  void _initOverrides(OverridesList? overrides) {
    if (overrides?.isNotEmpty ?? false) {
      this.overrides.addEntries(
        overrides!.map((e) {
          assert(
            e.$1.runtimeType == e.$2.runtimeType,
            ItemStore._assertFactoryOverrideReturnTypeMessage,
          );
          return MapEntry(e.$1, e.$2);
        }),
      );
    }
  }

  final ItemCacheMap _cache;

  @override
  @protected
  ItemCacheMap get cache => _cache;

  @override
  bool get isEmpty => _cache.isEmpty;

  @override
  bool contains(Object key) => cache.containsKey(key);

  @override
  final OverridesMap overrides = {};

  /// Reads the cached value stored with [key].
  /// You can calculate your global key with [ItemStore.keyFrom],
  /// or [ItemStore.valueKeyFrom].
  @override
  T? readByKey<T>(Object key) {
    return (_cache[key] as Item<T>?)?.data;
  }

  @override
  T write<T>(ItemFactory<T> itemFactory, {Object? key}) {
    final factoryOverride = overrides[itemFactory];
    final isOverridden = factoryOverride != null;

    final actualKey = ItemStore.keyFrom(itemFactory, key);
    final ref = Ref(store: this, key: actualKey);

    late final T result;

    if (isOverridden) {
      result = factoryOverride(ref);
    } else {
      result = itemFactory(ref);
    }

    // schedule the disposal of the item's local store
    ref.onDispose(ref.local.dispose);

    // dispose old item stored with same key
    if (_cache.containsKey(actualKey)) {
      disposeItem(actualKey);
    }

    _cache[actualKey] = Item<T>(result, ref);

    return result;
  }

  @override
  T? read<T>(ItemFactory<T> itemFactory, {Object? key}) {
    return readByKey<T>(ItemStore.keyFrom(itemFactory, key));
  }

  @override
  T get<T>(ItemFactory<T> itemFactory, {Object? key}) {
    final realKey = ItemStore.keyFrom(itemFactory, key);
    final maybeItem = readItem<T>(realKey);
    if (maybeItem != null) {
      return maybeItem.data;
    }
    return write<T>(itemFactory, key: key);
  }

  @override
  T? readValue<T>([Object? tag]) {
    return readByKey<T>(ItemStore.valueKeyFrom(T, tag: tag));
  }

  @override
  T writeValue<T>(T value, {Object? tag, bool disposable = false, void Function(T)? dispose}) {
    return write<T>((Ref ref) {
      if (disposable && value != null) {
        if (dispose == null) {
          ref.disposable<Object>(value);
        } else {
          ref.disposable<Object>(value, (o) => dispose(o as T));
        }
      }
      return value;
    }, key: ItemStore.valueKeyFrom(T, tag: tag));
  }

  @override
  void disposeValue<T>([Object? tag]) {
    disposeItem(ItemStore.valueKeyFrom(T, tag: tag));
  }

  /// Overrides the [from] factory with the [to] factory. So when creating
  /// an item (whether trough [write] or [get]), the [to] factory will be
  /// used instead of the original one, even if both an itemFactory and a
  /// global key is given.
  ///
  /// The overriding factory must have the same return type as the original one.
  ///
  /// If an item is already created with the original factory, it won't be affected
  /// by this override.
  ///
  /// This overrides an item factory (not a value of a key). If you just want
  /// to override the value of a key, consider using [write] instead.
  @override
  void overrideFactory<T>(ItemFactory<T> from, ItemFactory<T> to) {
    assert(from.runtimeType == to.runtimeType, ItemStore._assertFactoryOverrideReturnTypeMessage);
    overrides[from] = to;
  }

  @override
  void removeOverrideFrom(ItemFactory factory) {
    overrides.remove(factory);
  }

  @override
  T run<T>(ItemFactory<T> itemFactory) {
    final factoryOverride = overrides[itemFactory];
    final isOverridden = factoryOverride != null;

    // TODO unsupport ref.key
    final ref = Ref(store: this, key: Object());

    late final T result;

    if (isOverridden) {
      result = factoryOverride(ref);
    } else {
      result = itemFactory(ref);
    }

    // schedule the disposal of the item's local store
    ref.onDispose(ref.local.dispose);

    Item<T>(result, ref).dispose();

    return result;
  }

  @override
  Item<T>? readItem<T>(Object key) {
    return _cache[key] as Item<T>?;
  }

  /// Disposes the item and then removes it from the cache.
  @override
  void disposeItem(Object globalKey) {
    final item = _cache[globalKey];
    if (item == null) return;

    item.dispose();

    _cache.remove(globalKey);
  }

  /// Calls [disposeItem] for each key in [globalKeys].
  @override
  void disposeItems(Iterable<Object> globalKeys) {
    globalKeys.forEach(disposeItem);
  }

  /// Disposes items, clears cache and overrides.
  @override
  void dispose() {
    while (_cache.isNotEmpty) {
      disposeItem(_cache.keys.last);
    }
    _cache.clear();
    overrides.clear();
  }
}

extension type CallableItemStore<IS extends ItemStore>(IS ogApi) implements ItemStore {
  T call<T>(ItemFactory<T> itemFactory, {Object? key}) {
    return get<T>(itemFactory, key: key);
  }
}
