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

class Ref {
  Ref({
    required ItemStore store,
    required this.globalKey,
    this.tag,
    this.args,
    CallableItemStore? localStore,
  })  : _store = store,
        local = localStore ?? CallableItemStore(SimpleItemStore());

  final ItemStore _store;

  /// An [ItemStore] exclusive to this [Ref], so you can reuse factory functions
  /// to create local data.
  ///
  /// It also adds a convenience call method for [ItemStore.get] to reduce
  /// boilerplate.
  final CallableItemStore local;

  /// The global key of the item.
  final Object globalKey;

  /// The tag of the item if not null.
  final Object? tag;

  final Object? args;

  final ItemMetaData itemMetaData = ItemMetaData();

  T call<T>(
    ItemFactory<T> itemFactory, {
    Object? globalKey,
    Object? tag,
    Object? args,
  }) =>
      _store.get<T>(itemFactory, globalKey: globalKey, tag: tag, args: args);

  T getw<T>(
    ItemFactory<T> itemFactory, {
    Object? globalKey,
    Object? tag,
  }) =>
      _store.getw<T>(itemFactory, globalKey: globalKey, tag: tag);

  T create<T>(
    ItemFactory<T> itemFactory, {
    Object? globalKey,
    Object? tag,
    Object? args,
  }) {
    return _store.create(
      itemFactory,
      globalKey: globalKey,
      tag: tag,
      args: args,
    );
  }

  T createw<T>(
    ItemFactory<T> itemFactory, {
    Object? globalKey,
    Object? tag,
  }) {
    return _store.createw(
      itemFactory,
      globalKey: globalKey,
      tag: tag,
    );
  }

  T read<T>(Object globalKey) => _store.read(globalKey);

  T? readValue<T>([Object? tag]) =>
      _store.read<T>(ItemStore.valueKeyFrom(T, tag: tag));

  T createValue<T>(T value, {Object? tag}) => _store.create<T>(
        (_) => value,
        globalKey: ItemStore.valueKeyFrom(T, tag: tag),
      );

  void disposeSelf() => _store.disposeItem(globalKey);

  /// Adds [callback] to the list of dispose callbacks.
  void onDispose(ItemDisposeCallback callback) {
    itemMetaData.disposeCallbacks.add(callback);
  }

  void removeDisposeCallback(ItemDisposeCallback callback) {
    itemMetaData.disposeCallbacks.remove(callback);
  }
}

class LazyRef implements Ref {
  /// Creates Ref without having to initialize the globalKey, tag and args
  /// in the constructor.
  /// You must call [init] later, before passing it to the actual item factory!
  LazyRef({
    required ItemStore store,
    Object? globalKey,
    this.tag,
    bool checkKeyInStore = false,
    this.isOverridden = false,
    CallableItemStore? localStore,
  })  : _store = store,
        _globalKey = globalKey,
        local = localStore ?? CallableItemStore(SimpleItemStore()),
        _checkKeyInStore = checkKeyInStore,
        _isInitialized = false;

  @override
  final ItemStore _store;

  /// An [ItemStore] exclusive to this [Ref], so you can reuse factory functions
  /// to create local data.
  ///
  /// It also adds a convenience call method for [ItemStore.get] to reduce
  /// boilerplate.
  @override
  final CallableItemStore local;

  @override
  final ItemMetaData itemMetaData = ItemMetaData();

  bool _isInitialized;
  bool get isInitialized => _isInitialized;

  final bool isOverridden;

  Object? _globalKey;

  @override
  Object get globalKey {
    if (!isInitialized) {
      throw UninitializedException('globalKey was not initialized.');
    }

    return _globalKey!;
  }

  /// The tag of the item if not null.
  @override
  final Object? tag;

  late final Object? _args;
  @override
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

    _globalKey ??= ItemStore.globalKeyFrom(itemFactory: itemFactory, tag: tag);

    if (isOverridden) throw OverriddenException();

    if (_checkKeyInStore) {
      final value = _store.read(globalKey);
      if (value != null) throw RedundantKeyException(value);
    }
  }

  @override
  T call<T>(
    ItemFactory<T> itemFactory, {
    Object? globalKey,
    Object? tag,
    Object? args,
  }) =>
      _store.get<T>(itemFactory, globalKey: globalKey, tag: tag, args: args);

  @override
  T getw<T>(
    ItemFactory<T> itemFactory, {
    Object? globalKey,
    Object? tag,
  }) =>
      _store.getw<T>(itemFactory, globalKey: globalKey, tag: tag);

  @override
  T create<T>(
    ItemFactory<T> itemFactory, {
    Object? globalKey,
    Object? tag,
    Object? args,
  }) {
    return _store.create(
      itemFactory,
      globalKey: globalKey,
      tag: tag,
      args: args,
    );
  }

  @override
  T createw<T>(
    ItemFactory<T> itemFactory, {
    Object? globalKey,
    Object? tag,
  }) {
    return _store.createw(
      itemFactory,
      globalKey: globalKey,
      tag: tag,
    );
  }

  @override
  T read<T>(Object globalKey) => _store.read(globalKey);

  @override
  T? readValue<T>([Object? tag]) =>
      _store.read<T>(ItemStore.valueKeyFrom(T, tag: tag));

  @override
  T createValue<T>(T value, {Object? tag}) => _store.create<T>(
        (_) => value,
        globalKey: ItemStore.valueKeyFrom(T, tag: tag),
      );

  @override
  void disposeSelf() => _store.disposeItem(globalKey);

  /// Adds [callback] to the list of dispose callbacks.
  @override
  void onDispose(ItemDisposeCallback callback) {
    itemMetaData.disposeCallbacks.add(callback);
  }

  @override
  void removeDisposeCallback(ItemDisposeCallback callback) {
    itemMetaData.disposeCallbacks.remove(callback);
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
    // dispose object when the item is being removed from the store
    onDispose(
      dispose == null ? (object as dynamic).dispose : () => dispose(object),
    );

    return object;
  }

  /// Bind the given [object] object to this ref, meaning if any of them gets disposed,
  /// both of them will be disposed.
  ///
  /// [object] must have:
  /// - a void dispose() function or provide [disposeObject],
  /// - a void onDispose(void Function()) function or provide [disposeItem].
  ///
  /// See also:
  /// - [disposable] for one way binding,
  /// - [DisposableMixin] to add the required functions to your class.
  T bindTo<T>(
    T object, {
    void Function(T)? disposeObject,
    void Function(void Function())? disposeItem,
  }) {
    // dispose object when the item is being removed from the store
    onDispose(
      disposeObject == null
          ? (object as dynamic).dispose
          : () => disposeObject(object),
    );

    // dispose item from the store, when object gets disposed
    if (disposeItem == null) {
      (object as dynamic).onDispose(disposeSelf);
    } else {
      disposeItem(disposeSelf);
    }

    return object;
  }
}
