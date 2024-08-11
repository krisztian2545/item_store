import 'item.dart';
import 'item_store.dart';

class Ref {
  Ref({
    required ItemStore store,
    required this.globalKey,
    this.tag,
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

  final ItemMetaData itemMetaData = ItemMetaData();

  T call<T>(ItemFactory<T> itemFactory, {Object? globalKey, Object? tag}) =>
      _store.get<T>(itemFactory, globalKey: globalKey, tag: tag);

  T get<T>(ItemFactory<T> itemFactory, {Object? globalKey, Object? tag}) =>
      _store.get<T>(itemFactory, globalKey: globalKey, tag: tag);

  T create<T>(ItemFactory<T> itemFactory, {Object? globalKey, Object? tag}) {
    return _store.create(itemFactory, globalKey: globalKey, tag: tag);
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
