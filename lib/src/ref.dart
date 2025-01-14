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
    List<Object>? dependencies,
  }) =>
      _store.get<T>(
        itemFactory,
        globalKey: globalKey,
        tag: tag,
        dependencies: dependencies,
      );

  T write<T>(
    ItemFactory<T> itemFactory, {
    Object? globalKey,
    Object? tag,
  }) {
    return _store.write<T>(
      itemFactory,
      globalKey: globalKey,
      tag: tag,
    );
  }

  T? read<T>(ItemFactory<T> itemFactory, {Object? tag}) =>
      _store.read<T>(itemFactory, tag: tag);

  T? readByKey<T>(Object globalKey) => _store.readByKey<T>(globalKey);

  T? readValue<T>([Object? tag]) =>
      _store.readByKey<T>(ItemStore.valueKeyFrom(T, tag: tag));

  T writeValue<T>(T value, {Object? tag}) => _store.write<T>(
        (_) => value,
        globalKey: ItemStore.valueKeyFrom(T, tag: tag),
      );

  void disposeSelf() => _store.disposeItem(globalKey);

  /// Adds [callback] to the list of dispose callbacks.
  void onDispose(ItemDisposeCallback callback) {
    if (itemMetaData.disposeCallbacks.contains(callback)) return;
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
    List<Object>? dependencies,
    CallableItemStore? localStore,
  })  : _store = store,
        _globalKey = globalKey,
        local = localStore ?? CallableItemStore(SimpleItemStore()),
        _checkKeyInStore = checkKeyInStore,
        _isInitialized = false,
        itemMetaData = ItemMetaData(dependecies: dependencies);

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
  final ItemMetaData itemMetaData;

  bool _isInitialized;
  bool get isInitialized => _isInitialized;

  final bool isOverridden;

  Object? _globalKey;

  @override
  Object get globalKey {
    if (!isInitialized) {
      throw UninitializedException(
          'globalKey was not initialized. You probably just forgot to wrap the factory with ".p()"');
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
      final value = _store.cache[globalKey];

      if (ItemStore.dependciesAreSameFor(
        value,
        newDependencies: itemMetaData.dependecies,
      )) {
        throw RedundantKeyException(value!.data);
      }
    }
  }

  @override
  T call<T>(
    ItemFactory<T> itemFactory, {
    Object? globalKey,
    Object? tag,
    List<Object>? dependencies,
  }) =>
      _store.get<T>(
        itemFactory,
        globalKey: globalKey,
        tag: tag,
        dependencies: dependencies,
      );

  @override
  T write<T>(
    ItemFactory<T> itemFactory, {
    Object? globalKey,
    Object? tag,
  }) {
    return _store.write<T>(
      itemFactory,
      globalKey: globalKey,
      tag: tag,
    );
  }

  @override
  T? read<T>(ItemFactory<T> itemFactory, {Object? tag}) =>
      _store.read<T>(itemFactory, tag: tag);

  @override
  T? readByKey<T>(Object globalKey) => _store.readByKey<T>(globalKey);

  @override
  T? readValue<T>([Object? tag]) =>
      _store.readByKey<T>(ItemStore.valueKeyFrom(T, tag: tag));

  @override
  T writeValue<T>(T value, {Object? tag}) => _store.write<T>(
        (_) => value,
        globalKey: ItemStore.valueKeyFrom(T, tag: tag),
      );

  @override
  void disposeSelf() => _store.disposeItem(globalKey);

  /// Adds [callback] to the list of dispose callbacks, if not already added.
  @override
  void onDispose(ItemDisposeCallback callback) {
    if (itemMetaData.disposeCallbacks.contains(callback)) return;
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
    if (itemMetaData.disposableObjects.contains(object)) {
      return object;
    }

    bool disposing = false;

    // dispose object when the item is being removed from the store
    onDispose(
      () {
        if (disposing) return;
        disposing = true;

        dispose == null ? (object as dynamic).dispose() : dispose(object);
      },
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
    if (itemMetaData.disposableObjects.contains(object)) return object;

    bool disposing = false;

    // dispose object when the item is being removed from the store
    onDispose(() {
      if (disposing) return;
      disposing = true;

      disposeObject == null
          ? (object as dynamic).dispose()
          : disposeObject(object);
    });

    // dispose item from the store, when object gets disposed
    void safeDisposeSelf() {
      if (disposing) return;
      disposing = true;

      disposeSelf();
    }

    if (disposeItem == null) {
      (object as dynamic).onDispose(safeDisposeSelf);
    } else {
      disposeItem(safeDisposeSelf);
    }

    return object;
  }

  /// Calls the provided function only once.
  /// If you want to use more than one function to be called once,
  /// use the [tag] to differentiate them.
  void callOnce(Function() oneOffFun, {Object? tag}) {
    local(((_) => oneOffFun()).p(), globalKey: (callOnce, tag));
  }
}

extension ObjectUtilsForRefX<T extends Object> on T {
  T disposeWith(Ref ref, [void Function(T)? dispose]) =>
      ref.disposable(this, dispose);

  T bindTo(
    Ref ref, {
    void Function(T)? disposeObject,
    void Function(void Function())? disposeItem,
  }) =>
      ref.bindTo(
        this,
        disposeObject: disposeObject,
        disposeItem: disposeItem,
      );
}
