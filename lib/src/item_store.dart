import 'item.dart';
import 'ref.dart';

typedef ItemFactory<T> = T Function(Ref);

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

  static Object valueKeyFrom(Type type, {Object? tag}) =>
      tag == null ? type : (type, tag);

  /// Please don't use this unless you really have to.
  ItemCacheMap get cache;

  bool get isEmpty;

  OverridesMap get overrides;

  /// Creates an object by calling [itemFactory] and writes it into the cache
  /// with a global key, by which you can get it back later with [read].
  /// If there is an object cached with the same global key, then it will be
  /// overwritten.
  ///
  /// {@macro global_key_from}
  T create<T>(ItemFactory<T> itemFactory, {Object? globalKey, Object? tag});

  /// Reads the cached value stored with [globalKey].
  /// You can calculate your global key with [globalKeyFrom].
  T? read<T>(Object globalKey);

  /// [create]s an item or [read]s it if it's already cached.
  T get<T>(ItemFactory<T> itemFactory, {Object? globalKey, Object? tag});

  /// Stores the given [value] with a global key of it's type ([T]), or as a
  /// record consisting of [T] and [tag] if it's not null (like (T, tag)).
  ///
  /// Example:
  /// ```dart
  /// // without a tag
  /// store.create((_) => "John", globalKey: String);
  /// store.createValue<String>("John"); // achieves the same as above
  /// // with a tag
  /// store.create((_) => "John", globalKey: (String, "the second"));
  /// store.createValue<String>("John", tag: "the second"); // achieves the same as above
  /// ```
  T createValue<T>(T value, {Object? tag});

  /// Reads the cached value stored with a key that is either the [T] type,
  /// or a record consisting of the type ([T]) and [tag] if it's not null (like (T, tag)).
  ///
  /// Example:
  /// ```dart
  /// store.createValue<Person>(Person("John"));
  /// store.createValue<Person>(Person("Jane"), tag: "manager");
  /// store.createValue<Person>(Person("Jack"), tag: "tester");
  /// final person = store.readValue<Person>(); // John
  /// final manager = store.readValue<Person>("manager"); // Jane
  /// final tester = store.readValue<Person>("tester"); // Jack
  /// ```
  T? readValue<T>([Object? tag]);

  /// Disposes the item and then removes it from the cache.
  void disposeItem(Object globalKey);

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
  void overrideFactory<T>(ItemFactory<T> from, ItemFactory<T> to);

  void removeOverrideFrom(ItemFactory factory);

  /// Calls [disposeItem] for each key in [globalKeys].
  void disposeItems(Iterable<Object> globalKeys);

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

  /// Creates an object by calling [itemFactory] and writes it into the cache
  /// with a global key, by which you can get it back later with [read].
  /// If there is an object cached with the same global key, then it will be
  /// overwritten.
  ///
  /// {@macro global_key_from}
  @override
  T create<T>(ItemFactory<T> itemFactory, {Object? globalKey, Object? tag}) {
    final key = ItemStore.globalKeyFrom(
      globalKey: globalKey,
      itemFactory: itemFactory,
      tag: tag,
    );

    final ref = Ref(store: this, globalKey: key, tag: tag);
    final result = _overrides[itemFactory]?.call(ref) ?? itemFactory(ref);

    // schedule the disposal of the item's local store
    ref.onDispose(() => ref.local.dispose());

    // dispose old item stored with same key
    if (_cache.containsKey(key)) {
      disposeItem(key);
    }

    _cache[key] = Item<T>(result, ref.itemMetaData);

    return result;
  }

  /// Reads the cached value stored with [globalKey].
  /// You can calculate your global key with [globalKeyFrom].
  @override
  T? read<T>(Object globalKey) {
    return (_cache[globalKey] as Item<T>?)?.data;
  }

  /// [create]s an item or [read]s it if it's already cached.
  @override
  T get<T>(ItemFactory<T> itemFactory, {Object? globalKey, Object? tag}) {
    final key = ItemStore.globalKeyFrom(
      globalKey: globalKey,
      itemFactory: itemFactory,
      tag: tag,
    );
    return read<T>(key) ?? create(itemFactory, globalKey: key);
  }

  @override
  T? readValue<T>([Object? tag]) =>
      read<T>(ItemStore.valueKeyFrom(T, tag: tag));

  @override
  T createValue<T>(T value, {Object? tag}) =>
      create<T>((_) => value, globalKey: ItemStore.valueKeyFrom(T, tag: tag));

  /// Disposes the item and then removes it from the cache.
  @override
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

  /// Calls [disposeItem] for each key in [globalKeys].
  @override
  void disposeItems(Iterable<Object> globalKeys) =>
      globalKeys.forEach(disposeItem);

  @override
  bool get isEmpty => _cache.isEmpty;

  /// Disposes items and clears cache.
  @override
  void dispose() {
    disposeItems(_cache.keys);
    _cache.clear();
  }
}

/// An [ItemStore] implementation that can shadow the values the given store.
// class ShadowStore implements ItemStore {
//   ShadowStore({
//     this.parent,
//     OverridesList? overrides,
//   }) : _cache = {} {
//     _initOverrides(overrides);
//   }

//   ShadowStore.from(
//     ItemCacheMap map, {
//     this.parent,
//     OverridesList? overrides,
//   }) : _cache = map {
//     _initOverrides(overrides);
//   }

//   void _initOverrides(OverridesList? overrides) {
//     if (overrides?.isNotEmpty ?? false) {
//       _overrides.addEntries(overrides!.map((e) {
//         assert(
//           e.$1.runtimeType == e.$2.runtimeType,
//           ItemStore._assertFactoryOverrideReturnTypeMessage,
//         );
//         return MapEntry(e.$1, e.$2);
//       }));
//     }
//   }

//   final ItemStore? parent;

//   ItemStore get root => switch (parent) {
//         null => this,
//         ShadowStore() => (parent as ShadowStore).root,
//         _ => parent!,
//       };

//   final ItemCacheMap _cache;

//   /// Please don't use this unless you really have to.
//   @override
//   ItemCacheMap get cache => _cache;

//   final OverridesMap _overrides = {};

//   @override
//   OverridesMap get overrides => _overrides;

//   /// Creates an object by calling [itemFactory] and writes it into the cache
//   /// with a global key, by which you can get it back later with [read].
//   /// If there is an object cached with the same global key, then it will be
//   /// overwritten.
//   ///
//   /// {@macro global_key_from}
//   @override
//   T create<T>(ItemFactory<T> itemFactory, {Object? globalKey, Object? tag}) {
//     final key = ItemStore.globalKeyFrom(
//       globalKey: globalKey,
//       itemFactory: itemFactory,
//       tag: tag,
//     );

//     final ref = Ref(store: this, globalKey: key, tag: tag);
//     final T result = _overrides[itemFactory]?.call(ref) ??
//         parent?.overrides[itemFactory]?.call(ref) ??
//         itemFactory(ref);

//     // schedule the disposal of the item's local store
//     ref.onDispose(() => ref.local.dispose());

//     // dispose old item stored with same key
//     if (_cache.containsKey(key)) {
//       disposeItem(key);
//     }

//     _cache[key] = Item<T>(result, ref.itemMetaData);

//     return result;
//   }

//   /// Reads the cached value stored with [globalKey].
//   /// You can calculate your global key with [globalKeyFrom].
//   @override
//   T? read<T>(Object globalKey) {
//     return (_cache[globalKey] as Item<T>?)?.data ?? parent?.read(globalKey);
//   }

//   /// [create]s an item or [read]s it if it's already cached.
//   @override
//   T get<T>(ItemFactory<T> itemFactory, {Object? globalKey, Object? tag}) {
//     final key = ItemStore.globalKeyFrom(
//       globalKey: globalKey,
//       itemFactory: itemFactory,
//       tag: tag,
//     );
//     return read<T>(key) ?? create(itemFactory, globalKey: key);
//   }

//   /// Disposes the item and then removes it from the cache.
//   @override
//   void disposeItem(Object globalKey) {
//     final item = _cache[globalKey];
//     if (item == null) {
//       parent?.disposeItem(globalKey);
//       return;
//     }

//     item.dispose();

//     _cache.remove(globalKey);
//   }

//   /// Overrides the [from] factory with the [to] factory. So when creating
//   /// an item (whether trough [create] or [get]), the [to] factory will be
//   /// used instead of the original one, even if both an itemFactory and a
//   /// global key is given.
//   ///
//   /// The overriding factory must have the same return type as the original one.
//   ///
//   /// If an item is already created with the original factory, it won't be affected
//   /// by this override.
//   ///
//   /// This overrides an item factory (not a value of a key). If you just want
//   /// to override the value of a key, consider using [create] instead.
//   @override
//   void overrideFactory<T>(ItemFactory<T> from, ItemFactory<T> to) {
//     assert(
//       from.runtimeType == to.runtimeType,
//       ItemStore._assertFactoryOverrideReturnTypeMessage,
//     );
//     _overrides[from] = to;
//   }

//   @override
//   void removeOverrideFrom(ItemFactory factory) {
//     _overrides.remove(factory);
//   }

//   /// Calls [disposeItem] for each key in [globalKeys].
//   @override
//   void disposeItems(Iterable<Object> globalKeys) =>
//       globalKeys.forEach(disposeItem);

//   @override
//   bool get isEmpty => _cache.isEmpty;

//   /// Disposes items and clears cache.
//   @override
//   void dispose() {
//     disposeItems(_cache.keys);
//     _cache.clear();
//   }
// }

extension type CallableItemStore(ItemStore _store) implements ItemStore {
  T call<T>(ItemFactory<T> itemFactory, {Object? globalKey, Object? tag}) =>
      _store.get<T>(itemFactory, globalKey: globalKey, tag: tag);
}
