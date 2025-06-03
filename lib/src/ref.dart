import 'package:item_store/item_store.dart';
import 'package:item_store/src/items_api.dart';

class Ref with ProxyItemsApi {
  /// Creates Ref without having to initialize the globalKey, tag and args
  /// in the constructor.
  /// You must call [init] later, before passing it to the actual item factory!
  Ref({
    required ItemStore store,
    required this.globalKey,
    CallableItemStore? localStore,
  })  : _store = store,
        _local = localStore,
        itemMetaData = ItemMetaData();

  final ItemStore _store;

  CallableItemStore? _local;

  /// An [ItemStore] exclusive to this [Ref], so you can reuse factory functions
  /// to create local data.
  ///
  /// It also adds a convenience call method for [ItemStore.get] to reduce
  /// boilerplate.
  CallableItemStore get local => _lazyLocal();

  void _initLocal() {
    _local ??= CallableItemStore(SimpleItemStore());
  }

  CallableItemStore _getLocal() => _local!;
  late CallableItemStore Function() _lazyLocal = () {
    _initLocal();
    _lazyLocal = _getLocal;
    return _local!;
  };

  final ItemMetaData itemMetaData;

  final Object globalKey;

  void disposeSelf() {
    _store.disposeItem(globalKey);
  }

  /// Adds [callback] to the list of dispose callbacks, if not already added.
  void onDispose(ItemDisposeCallback callback) {
    itemMetaData.safeAddDisposeCallback(callback);
  }

  void removeDisposeCallback(ItemDisposeCallback callback) {
    itemMetaData.disposeCallbacks.remove(callback);
  }

  // ------------------------- [ItemStore] proxy API -------------------------

  @override
  ItemStore get proxyStory => _store;
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
    local((_) => oneOffFun(), globalKey: (callOnce, tag));
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
