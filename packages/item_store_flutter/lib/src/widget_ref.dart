import 'package:flutter/widgets.dart';
import 'package:item_store/item_store.dart';

class WidgetRef with DisposableMixin {
  WidgetRef({
    required ItemStore store,
    CallableItemStore? localStore,
  })  : _store = store,
        local = localStore ?? CallableItemStore(ItemStore());

  ItemStore _store;

  @protected
  void updateStore(ItemStore newStore) => _store = newStore;

  /// An [ItemStore] exclusive to this [Ref], so you can reuse factory functions
  /// to create local data.
  ///
  /// It also adds a convenience call method for [ItemStoreUtilX.get] to reduce
  /// boilerplate.
  final CallableItemStore local;

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

  T readByKey<T>(Object globalKey) => _store.readByKey(globalKey);

  T? readValue<T>([Object? tag]) =>
      _store.readByKey<T>(ItemStore.valueKeyFrom(T, tag: tag));

  T createValue<T>(T value, {Object? tag}) => _store.create<T>(
        (_) => value,
        globalKey: ItemStore.valueKeyFrom(T, tag: tag),
      );

  final _disposeCallbacks = <void Function()>[];
  final _disposableObjects = <Object>[];

  void onDispose(void Function() callback) {
    if (_disposeCallbacks.contains(callback)) return;
    _disposeCallbacks.add(callback);
  }

  /// Binds the provided [object] to the [onDispose] callback, allowing it to be
  /// disposed when the item gets disposed.
  ///
  /// The [object] either has to have a void dispose() function, or
  /// provide a custom [dispose] function that will be called instead.
  ///
  /// Returns the provided [object].
  ///
  /// It's safe to call this in a widget's build function, because it checks
  /// if [object] has already been registered for disposal.
  T disposable<T extends Object>(T object, [void Function(T)? dispose]) {
    if (_disposableObjects.contains(object)) return object;

    _disposableObjects.add(object);
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

  void removeDisposeCallback(void Function() callback) {
    _disposeCallbacks.remove(callback);
  }

  void dispose() {
    for (final callback in _disposeCallbacks) {
      callback();
    }
  }
}

extension ObjectUtilsForWidgetRefX<T extends Object> on T {
  T disposeWithWidget(WidgetRef ref, [void Function(T)? dispose]) =>
      ref.disposable(this, dispose);
}
