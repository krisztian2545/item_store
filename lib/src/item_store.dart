import 'package:item_store/src/item_factory.dart';

import 'item.dart';
import 'ref.dart';

part 'get_global_key_ref.dart';

typedef ItemCacheMap = Map<Object, Item>;

typedef OverridesMap = Map<ItemFactory, ItemFactory>;
typedef OverrideRecord<T> = (ItemFactory<T>, ItemFactory<T>);
typedef OverridesList = List<OverrideRecord>;

abstract interface class ItemStore {
  factory ItemStore({OverridesList? overrides}) =>
      SimpleItemStore(overrides: overrides);

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
  static Object globalKeyFrom<T>({
    required Function itemFactory,
    Object? args,
  }) {
    if (args == null) {
      return itemFactory;
    }
    return (itemFactory, args);
  }

  static Object extractGlobalKeyFrom<T>(ItemFactory<T> itemFactory) {
    final ref = _GetGlobalKeyRef();

    // set args in ref
    try {
      // should throw OverriddenException
      itemFactory(ref);
    } on OverriddenException {
      return ref.globalKey;
    }

    throw StateError("Failed to get global key.");
  }

  /// Calculates the global key of a value.
  static Object valueKeyFrom(Type type, {Object? tag}) =>
      tag == null ? type : (type, tag);

  ItemCacheMap get cache;

  bool get isEmpty;

  OverridesMap get overrides;

  /// Reads the cached value stored with [globalKey].
  /// You can calculate your global key with [ItemStore.globalKeyFrom],
  /// [ItemStore.extractGlobalKeyFrom] or [ItemStore.valueKeyFrom].
  T? readByKey<T>(Object globalKey);

  /// {@template create}
  /// Creates an object by calling [itemFactory] and writes it into the cache
  /// with a global key, by which you can get it back later with [read].
  /// If there is an object cached with the same global key, then it will be
  /// disposed and overwritten.
  ///
  /// {@macro global_key_from}
  /// {@endtemplate}
  T write<T>(ItemFactory<T> itemFactory, {Object? globalKey});

  /// Reads the cached value stored with a key calculated with [globalKeyFrom],
  /// where the args are determined inside the itemFactory's [p] function.
  T? read<T>(ItemFactory<T> itemFactory);

  /// {@template get}
  /// [write]s an item or [read]s it if it's already cached.
  /// {@endtemplate}
  T get<T>(ItemFactory<T> itemFactory, {Object? globalKey});

  void remove<T>(ItemFactory<T> itemFactory);

  /// Runs [itemFactory] the same way as [write] does, but doesn't store it into the cache.
  /// Useful to create functions that perform an action, rather then create data.
  ///
  /// Note: anything registered for disposal with ref is going to be disposed after the [itemFactory]
  /// has finished, and before returning from the result of it.
  T run<T>(ItemFactory<T> itemFactory);

  /// Stores the given [value] with a global key of it's type ([T]), or as a
  /// record consisting of [T] and [tag] if it's not null (like (T, tag)).
  ///
  /// Example:
  /// ```dart
  /// // without a tag
  /// store.write((_) => "John", globalKey: String);
  /// store.writeValue<String>("John"); // achieves the same as above
  /// // with a tag
  /// store.write((_) => "John", globalKey: (String, "the second"));
  /// store.writeValue<String>("John", tag: "the second"); // achieves the same as above
  /// ```
  T writeValue<T>(
    T value, {
    Object? tag,
    bool disposable,
    void Function(T)? dispose,
  });

  /// Reads the cached value stored with a key that is either the [T] type,
  /// or a record consisting of the type ([T]) and [tag] if it's not null (like (T, tag)).
  ///
  /// Example:
  /// ```dart
  /// store.writeValue<Person>(Person("John"));
  /// store.writeValue<Person>(Person("Jane"), tag: "manager");
  /// store.writeValue<Person>(Person("Jack"), tag: "tester");
  /// final person = store.readValue<Person>(); // John
  /// final manager = store.readValue<Person>("manager"); // Jane
  /// final tester = store.readValue<Person>("tester"); // Jack
  /// ```
  T? readValue<T>([Object? tag]);

  void removeValue<T>([Object? tag]);

  /// Disposes the item and then removes it from the cache.
  void removeItem(Object globalKey);

  /// Overrides the [from] factory with the [to] factory. So when creating
  /// an item (whether trough [write] or [get]), the [to] factory will be
  /// used instead of the original one, even if both an itemFactory and a
  /// global key is given.
  ///
  /// The overriding factory must have the same return type as the original one.
  /// If you have created a custom [p] function for your factory, make sure they
  /// pass args the same way to [Ref.init].
  ///
  /// If an item is already created with the original factory, it won't be affected
  /// by this override.
  ///
  /// This overrides an item factory (not a value of a key). If you just want
  /// to override the value of a key, consider using [write] instead.
  void overrideFactory<T>(ItemFactory<T> from, ItemFactory<T> to);

  /// Removes the override from [factory], but doesn't delete the items
  /// created with it.
  void removeOverrideFrom(ItemFactory factory);

  void removeItems(Iterable<Object> globalKeys);

  /// Disposes items and clears cache.
  void dispose();
}

/// The most basic implementation of [ItemStore].
class SimpleItemStore implements ItemStore {
  SimpleItemStore({OverridesList? overrides}) : _cache = {} {
    _initOverrides(overrides);
  }

  SimpleItemStore.from(ItemCacheMap map, {OverridesList? overrides})
      : _cache = map {
    _initOverrides(overrides);
  }

  void _initOverrides(OverridesList? overrides) {
    if (overrides?.isNotEmpty ?? false) {
      _overrides.addEntries(overrides!.map((e) {
        assert(
          e.$1.runtimeType == e.$2.runtimeType,
          ItemStore._assertFactoryOverrideReturnTypeMessage,
        );
        return MapEntry(e.$1, e.$2);
      }));
    }
  }

  final ItemCacheMap _cache;

  /// Please don't use this unless you really have to.
  @override
  ItemCacheMap get cache => _cache;

  final OverridesMap _overrides = {};

  @override
  OverridesMap get overrides => _overrides;

  /// Reads the cached value stored with [globalKey].
  /// You can calculate your global key with [ItemStore.globalKeyFrom],
  /// [ItemStore.extractGlobalKeyFrom] or [ItemStore.valueKeyFrom].
  @override
  T? readByKey<T>(Object globalKey) {
    return (_cache[globalKey] as Item<T>?)?.data;
  }

  @override
  T write<T>(ItemFactory<T> itemFactory, {Object? globalKey}) {
    final factoryOverride = _overrides[itemFactory];
    final isOverridden = factoryOverride != null;

    final ref = Ref(
      store: this,
      globalKey: globalKey,
      checkKeyInStore: false,
      isOverridden: isOverridden,
    );

    late final T result;

    if (isOverridden) {
      // set args in ref
      try {
        // should throw OverriddenException
        itemFactory(ref);
      } on OverriddenException {
        // TODO why did this pass tests when I didn't store it in result?
        result = factoryOverride(ref);
      }
    } else {
      result = itemFactory(ref);
    }

    final key = ref.globalKey;

    // schedule the disposal of the item's local store
    ref.onDispose(ref.local.dispose);

    // dispose old item stored with same key
    if (_cache.containsKey(key)) {
      removeItem(key);
    }

    _cache[key] = Item<T>(result, ref.itemMetaData);

    return result;
  }

  @override
  T? read<T>(ItemFactory<T> itemFactory) {
    return readByKey(ItemStore.extractGlobalKeyFrom(itemFactory));
  }

  @override
  T get<T>(ItemFactory<T> itemFactory, {Object? globalKey}) {
    final factoryOverride = _overrides[itemFactory];
    final isOverridden = factoryOverride != null;

    final ref = Ref(
      store: this,
      globalKey: globalKey,
      checkKeyInStore: true,
      isOverridden: isOverridden,
    );

    late final T result;
    late final Object key;

    if (isOverridden) {
      // set args and globalKey in ref
      try {
        // should throw OverriddenException
        itemFactory(ref);
      } on OverriddenException {
        key = ref.globalKey;

        // return if there is already a value with this key
        final alreadyPresentItem = readByKey<T>(key);
        if (alreadyPresentItem != null) {
          return alreadyPresentItem;
        }

        result = factoryOverride(ref);
      }
    } else {
      try {
        result = itemFactory(ref);
        key = ref.globalKey;
      } on RedundantKeyException catch (e) {
        return e.readValue as T;
      }
    }

    // schedule the disposal of the item's local store
    ref.onDispose(ref.local.dispose);

    // dispose old item stored with same key
    if (_cache.containsKey(key)) {
      removeItem(key);
    }

    _cache[key] = Item<T>(result, ref.itemMetaData);

    return result;
  }

  @override
  void remove<T>(ItemFactory<T> itemFactory) {
    removeItem(ItemStore.extractGlobalKeyFrom(itemFactory));
  }

  @override
  T? readValue<T>([Object? tag]) {
    return readByKey<T>(ItemStore.valueKeyFrom(T, tag: tag));
  }

  @override
  T writeValue<T>(
    T value, {
    Object? tag,
    bool disposable = false,
    void Function(T)? dispose,
  }) {
    return write<T>(
      (Ref ref) {
        if (disposable && value != null) {
          if (dispose == null) {
            ref.disposable<Object>(value);
          } else {
            ref.disposable<Object>(value, (o) => dispose(o as T));
          }
        }
        return value;
      }.p(),
      globalKey: ItemStore.valueKeyFrom(T, tag: tag),
    );
  }

  @override
  void removeValue<T>([Object? tag]) {
    removeItem(ItemStore.valueKeyFrom(T, tag: tag));
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
    assert(
      from.runtimeType == to.runtimeType,
      ItemStore._assertFactoryOverrideReturnTypeMessage,
    );
    _overrides[from] = to;
  }

  @override
  void removeOverrideFrom(ItemFactory factory) {
    _overrides.remove(factory);
  }

  @override
  T run<T>(ItemFactory<T> itemFactory) {
    final factoryOverride = _overrides[itemFactory];
    final isOverridden = factoryOverride != null;

    final ref = Ref(
      store: this,
      checkKeyInStore: false,
      isOverridden: isOverridden,
    );

    late final T result;

    if (isOverridden) {
      // set args in ref
      try {
        // should throw OverriddenException
        itemFactory(ref);
      } on OverriddenException {
        // TODO why did this pass tests when I didn't store it in result?
        result = factoryOverride(ref);
      }
    } else {
      result = itemFactory(ref);
    }

    // schedule the disposal of the item's local store
    ref.onDispose(ref.local.dispose);

    Item<T>(result, ref.itemMetaData).dispose();

    return result;
  }

  /// Disposes the item and then removes it from the cache.
  @override
  void removeItem(Object globalKey) {
    final item = _cache[globalKey];
    if (item == null) return;

    item.dispose();

    _cache.remove(globalKey);
  }

  /// Calls [removeItem] for each key in [globalKeys].
  @override
  void removeItems(Iterable<Object> globalKeys) {
    globalKeys.forEach(removeItem);
  }

  @override
  bool get isEmpty => _cache.isEmpty;

  /// Disposes items and clears cache.
  @override
  void dispose() {
    removeItems([..._cache.keys]);
    _cache.clear();
  }
}

extension type CallableItemStore(ItemStore _store) implements ItemStore {
  T call<T>(ItemFactory<T> itemFactory, {Object? globalKey}) {
    return _store.get<T>(itemFactory, globalKey: globalKey);
  }
}
