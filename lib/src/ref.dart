import 'package:item_store/item_store.dart';

class UninitializedException implements Exception {
  UninitializedException([this.message]);
  final String? message;
}

class OverriddenException implements Exception {}

class RedundantKeyException<T> implements Exception {
  RedundantKeyException(this.readValue);
  // The value stored with the redundant key.
  final T readValue;
}

// class Ref {
//   Ref({
//     required ItemStore store,
//     required this.globalKey,
//     this.args,
//     CallableItemStore? localStore,
//   })  : _store = store,
//         local = localStore ?? CallableItemStore(SimpleItemStore());

//   final ItemStore _store;

//   /// An [ItemStore] exclusive to this [Ref], so you can reuse factory functions
//   /// to create local data.
//   ///
//   /// It also adds a convenience call method for [ItemStore.get] to reduce
//   /// boilerplate.
//   final CallableItemStore local;

//   /// The global key of the item.
//   final Object globalKey;

//   /// The tag of the item if not null.
//   final Object? args;

//   final ItemMetaData itemMetaData = ItemMetaData();

//   T call<T>(
//     ItemFactory<T> itemFactory, {
//     Object? globalKey,
//     Object? tag,
//     List<Object>? dependencies,
//   }) =>
//       _store.get<T>(
//         itemFactory,
//         globalKey: globalKey,
//         tag: tag,
//         dependencies: dependencies,
//       );

//   T write<T>(
//     ItemFactory<T> itemFactory, {
//     Object? globalKey,
//     Object? tag,
//   }) {
//     return _store.write<T>(
//       itemFactory,
//       globalKey: globalKey,
//       tag: tag,
//     );
//   }

//   T? read<T>(ItemFactory<T> itemFactory, {Object? tag}) =>
//       _store.read<T>(itemFactory, tag: tag);

//   T? readByKey<T>(Object globalKey) => _store.readByKey<T>(globalKey);

//   T? readValue<T>([Object? tag]) =>
//       _store.readByKey<T>(ItemStore.valueKeyFrom(T, tag: tag));

//   T writeValue<T>(T value, {Object? tag}) {
//     return _store.write<T>(
//       (_) => value,
//       globalKey: ItemStore.valueKeyFrom(T, tag: tag),
//     );
//   }

//   void disposeSelf() {
//     _store.disposeItem(globalKey);
//   }

//   /// Adds [callback] to the list of dispose callbacks.
//   void onDispose(ItemDisposeCallback callback) {
//     itemMetaData.safeAddDisposeCallback(callback);
//   }

//   void removeDisposeCallback(ItemDisposeCallback callback) {
//     itemMetaData.disposeCallbacks.remove(callback);
//   }
// }

class Ref {
  /// Creates Ref without having to initialize the globalKey, tag and args
  /// in the constructor.
  /// You must call [init] later, before passing it to the actual item factory!
  Ref({
    required ItemStore store,
    Object? globalKey,
    bool checkKeyInStore = false,
    this.isOverridden = false,
    CallableItemStore? localStore,
  })  : _store = store,
        _globalKey = globalKey,
        local = localStore ?? CallableItemStore(SimpleItemStore()),
        _checkKeyInStore = checkKeyInStore,
        _isInitialized = false,
        itemMetaData = ItemMetaData();

  final ItemStore _store;

  /// An [ItemStore] exclusive to this [Ref], so you can reuse factory functions
  /// to create local data.
  ///
  /// It also adds a convenience call method for [ItemStore.get] to reduce
  /// boilerplate.
  final CallableItemStore local;

  final ItemMetaData itemMetaData;

  bool _isInitialized;
  bool get isInitialized => _isInitialized;

  final bool isOverridden;

  Object? _globalKey;

  Object get globalKey {
    if (!isInitialized) {
      throw UninitializedException(
          'globalKey was not initialized. You probably just forgot to wrap the factory with ".p()"');
    }

    return _globalKey!;
  }

  late final Object? _args;
  Object? get args {
    if (!isInitialized) {
      throw UninitializedException('args was not initialized.');
    }

    return _args;
  }

  final bool _checkKeyInStore;

  /// Inits globalKey, tag and args on the first call. Consecutive calls will
  /// be ignored.
  void init({
    required Function itemFactory,
    Object? args,
  }) {
    if (_isInitialized) return;
    _isInitialized = true;

    _args = args;

    _globalKey ??=
        ItemStore.globalKeyFrom(itemFactory: itemFactory, args: args);

    if (isOverridden) throw OverriddenException();

    if (_checkKeyInStore) {
      final value = _store.cache[globalKey];

      if (value != null) {
        throw RedundantKeyException(value.data);
      }
    }
  }

  void disposeSelf() {
    _store.removeItem(globalKey);
  }

  /// Adds [callback] to the list of dispose callbacks, if not already added.
  void onDispose(ItemDisposeCallback callback) {
    itemMetaData.safeAddDisposeCallback(callback);
  }

  void removeDisposeCallback(ItemDisposeCallback callback) {
    itemMetaData.disposeCallbacks.remove(callback);
  }

  // ------------------------- [ItemStore] proxy API -------------------------

  T? readByKey<T>(Object globalKey) => _store.readByKey<T>(globalKey);

  T write<T>(ItemFactory<T> itemFactory, {Object? globalKey}) {
    return _store.write<T>(itemFactory, globalKey: globalKey);
  }

  T? read<T>(ItemFactory<T> itemFactory) => _store.read<T>(itemFactory);

  T call<T>(ItemFactory<T> itemFactory, {Object? globalKey}) {
    return _store.get<T>(itemFactory, globalKey: globalKey);
  }

  void remove<T>(ItemFactory<T> itemFactory) {
    _store.remove<T>(itemFactory);
  }

  T run<T>(ItemFactory<T> itemFactory) {
    return _store.run<T>(itemFactory);
  }

  T writeValue<T>(
    T value, {
    Object? tag,
    bool disposable = false,
    void Function(T)? dispose,
  }) {
    return _store.writeValue<T>(
      value,
      tag: tag,
      disposable: disposable,
      dispose: dispose,
    );
  }

  T? readValue<T>([Object? tag]) => _store.readValue<T>(tag);

  void removeValue<T>([Object? tag]) {
    _store.removeValue<T>(tag);
  }

  void overrideFactory<T>(ItemFactory<T> from, ItemFactory<T> to) {
    _store.overrideFactory<T>(from, to);
  }

  void removeOverrideFrom(ItemFactory factory) {
    _store.removeOverrideFrom(factory);
  }

  void removeItem(Object globalKey) {
    _store.removeItem(globalKey);
  }

  void removeItems(Iterable<Object> globalKeys) {
    _store.removeItems(globalKeys);
  }
}

extension RefUtilsX on Ref {
  /// Binds the provided [object] to the [onDispose] callback, allowing it to be
  /// disposed when the item gets disposed.
  ///
  /// The [object] either has to have a void dispose() function, or
  /// provide a custom [dispose] function that will be called instead.
  ///
  /// Returns the provided [object].
  T disposable<T extends Object>(T object, [void Function(T)? dispose]) {
    return itemMetaData.safeAddDisposableObject<T>(object, dispose);
  }

  /// Bind the given [object] object to this ref, meaning if any of them gets disposed,
  /// both of them will be disposed.
  ///
  /// [object] must have:
  /// - a void dispose() function or provide [disposeObject],
  /// - a void onDispose(void Function()) function or provide [onObjectDispose].
  ///
  /// See also:
  /// - [disposable] for one way binding,
  /// - [DisposableMixin] to add the required functions to your class.
  T bindTo<T extends Object>(
    T object, {
    void Function(T)? dispose,
    void Function(void Function())? onObjectDispose,
  }) {
    return itemMetaData.safeBindTo<T>(
      object,
      dispose: dispose,
      onObjectDispose: onObjectDispose,
      disposeFromStore: disposeSelf,
    );
  }

  /// Calls the provided function only once.
  /// If you want to use more than one function to be called once,
  /// use the [tag] to differentiate them.
  void callOnce(Function() oneOffFun, {Object? tag}) {
    local(((_) => oneOffFun()).p(), globalKey: (callOnce, tag));
  }
}

extension ObjectUtilsForRefX<T extends Object> on T {
  T disposeWith(Ref ref, [void Function(T)? dispose]) {
    return ref.disposable<T>(this, dispose);
  }

  T bindTo(
    Ref ref, {
    void Function(T)? dispose,
    void Function(void Function() disposeItemFromStore)? onObjectDispose,
  }) {
    return ref.bindTo<T>(
      this,
      dispose: dispose,
      onObjectDispose: onObjectDispose,
    );
  }
}
