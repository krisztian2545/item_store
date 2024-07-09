import 'item.dart';
import 'item_store.dart';

class Ref {
  Ref({
    required ItemStore store,
    required this.itemKey,
    this.itemTag,
    LocalItemStore? localStore,
  })  : _store = store,
        local = localStore ?? LocalItemStore(ItemStore());

  final ItemStore _store;

  /// An [ItemStore] exclusive to this [Ref], so you can reuse factory functions
  /// to create local data.
  ///
  /// It also adds a convenience call method for [ItemStoreUtilX.get] to reduce
  /// boilerplate.
  final LocalItemStore local;

  /// The global key of the item.
  final Object itemKey;

  /// The tag of the item if not null.
  final Object? itemTag;

  final ItemMetaData itemMetaData = ItemMetaData();

  T call<T>(ItemFactory<T> itemFactory, {Object? globalKey, Object? tag}) =>
      _store.get<T>(itemFactory, globalKey: globalKey, tag: tag);

  T create<T>(ItemFactory<T> itemFactory, {Object? globalKey, Object? tag}) {
    return _store.create(itemFactory, globalKey: globalKey, tag: tag);
  }

  T read<T>(Object globalKey) => _store.read(globalKey);

  void disposeSelf() => _store.disposeItem(itemKey);

  /// Adds [callback] to the list of dispose callbacks.
  void onDispose(ItemDisposeCallback callback) {
    itemMetaData.disposeCallbacks.add(callback);
  }

  void removeDisposeCallback(ItemDisposeCallback callback) {
    itemMetaData.disposeCallbacks.remove(callback);
  }
}

extension RefUtilsX on Ref {
  /// Calls the provided object's dispose function on [onDispose].
  /// [disposable] must have a void dispose() function.
  T registerDisposable<T extends Object>(T disposable,
      {bool assertCompatibility = true}) {
    void bind(o) {
      // dispose object when being removed from the store
      onDispose(o.dispose);
    }

    if (assertCompatibility) {
      bind(disposable);
    } else {
      try {
        bind(disposable);
      } catch (e) {
        // disposable doesn't have a void dispose() function.
      }
    }

    return disposable;
  }

  /// Alias for [registerDisposable].
  T d<T extends Object>(T disposable) => registerDisposable(disposable);

  /// Bind the given [disposable] object to this ref, meaning if any of them gets disposed,
  /// both of them will be disposed.
  ///
  /// [disposable] must have:
  /// - a void dispose() function,
  /// - a void onDispose(void Function()) function.
  ///
  /// If [assertCompatibility] is false, no error will be thrown when
  /// [disposable] doesn't have one or all of the required functions.
  ///
  /// See also:
  /// - [registerDisposable] for one way binding,
  /// - [DisposableMixin] to add the required functions to your class.
  T bindToDisposable<T>(T disposable, {bool assertCompatibility = true}) {
    void bind(o) {
      // dispose object when being removed from the store
      onDispose(o.dispose);

      // dispose item from the store, when object gets disposed
      o.onDispose(disposeSelf);
    }

    if (assertCompatibility) {
      bind(disposable);
    } else {
      try {
        bind(disposable);
      } catch (e) {
        // disposable doesn't have a void dispose() function
        // or doesn't accept an onDispose callback.
      }
    }

    return disposable;
  }
}
