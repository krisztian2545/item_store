import 'package:item_store/item_store.dart';

abstract mixin class ItemsApi {
  /// Reads the cached value stored with [key].
  /// You can calculate your global key with [ItemStore.keyFrom],
  /// [ItemStore.extractGlobalKeyFrom] or [ItemStore.valueKeyFrom].
  T? readByKey<T>(Object key);

  T? read<T>(ItemFactory<T> itemFactory, {Object? key});

  /// {@template create}
  /// Creates an object by calling [itemFactory] and writes it into the cache
  /// with a global key, by which you can get it back later with [read].
  /// If there is an object cached with the same global key, then it will be
  /// disposed and overwritten.
  ///
  /// {@macro global_key_from}
  /// {@endtemplate}
  T write<T>(ItemFactory<T> itemFactory, {Object? key});

  /// {@template get}
  /// [write]s an item or [read]s it if it's already cached.
  /// {@endtemplate}
  T get<T>(ItemFactory<T> itemFactory, {Object? key});

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
  T writeValue<T>(T value, {Object? tag, bool disposable, void Function(T)? dispose});

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

  void disposeValue<T>([Object? tag]);

  Item<T>? readItem<T>(Object key);

  /// Disposes the item and then removes it from the cache.
  void disposeItem(Object key);

  void disposeItems(Iterable<Object> keys);

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
}

abstract mixin class ProxyItemsApi<IS extends ItemStore> implements ItemsApi {
  IS get proxiedStore;

  @override
  T? readByKey<T>(Object key) => proxiedStore.readByKey<T>(key);

  @override
  T? read<T>(ItemFactory<T> itemFactory, {Object? key}) =>
      proxiedStore.read<T>(itemFactory, key: key);

  @override
  T write<T>(ItemFactory<T> itemFactory, {Object? key}) {
    return proxiedStore.write<T>(itemFactory, key: key);
  }

  T call<T>(ItemFactory<T> itemFactory, {Object? key}) {
    return proxiedStore.get<T>(itemFactory, key: key);
  }

  @override
  T get<T>(ItemFactory<T> itemFactory, {Object? key}) {
    return proxiedStore.get<T>(itemFactory, key: key);
  }

  @override
  T run<T>(ItemFactory<T> itemFactory) {
    return proxiedStore.run<T>(itemFactory);
  }

  @override
  T writeValue<T>(T value, {Object? tag, bool disposable = false, void Function(T)? dispose}) {
    return proxiedStore.writeValue<T>(value, tag: tag, disposable: disposable, dispose: dispose);
  }

  @override
  T? readValue<T>([Object? tag]) => proxiedStore.readValue<T>(tag);

  @override
  void disposeValue<T>([Object? tag]) {
    proxiedStore.disposeValue<T>(tag);
  }

  @override
  void overrideFactory<T>(ItemFactory<T> from, ItemFactory<T> to) {
    proxiedStore.overrideFactory<T>(from, to);
  }

  @override
  void removeOverrideFrom(ItemFactory factory) {
    proxiedStore.removeOverrideFrom(factory);
  }

  @override
  Item<T>? readItem<T>(Object key) {
    return proxiedStore.readItem<T>(key);
  }

  @override
  void disposeItem(Object key) {
    proxiedStore.disposeItem(key);
  }

  @override
  void disposeItems(Iterable<Object> keys) {
    proxiedStore.disposeItems(keys);
  }
}
