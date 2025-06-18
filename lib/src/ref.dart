import 'package:item_store/item_store.dart';

class Ref with ProxyItemsApi {
  /// Creates Ref without having to initialize the globalKey, tag and args
  /// in the constructor.
  /// You must call [init] later, before passing it to the actual item factory!
  Ref({
    required ItemStore store,
    required this.key,
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

  CallableItemStore _getLocal() => _local!;
  late CallableItemStore Function() _lazyLocal = () {
    _local ??= CallableItemStore(SimpleItemStore());
    _lazyLocal = _getLocal;
    return _local!;
  };

  final ItemMetaData itemMetaData;

  final Object key;

  void disposeSelf() {
    _store.disposeItem(key);
  }

  /// Adds [callback] to the list of dispose callbacks, if not already added.
  void onDispose(ItemDisposeCallback callback) {
    itemMetaData.addDisposeCallback(callback);
  }

  void removeDisposeCallback(ItemDisposeCallback callback) {
    itemMetaData.removeDisposeCallback(callback);
  }

  void removeDisposableObject(Object object) {
    itemMetaData.removeDisposableObject(object);
  }

  // ------------------------- [ItemStore] proxy API -------------------------

  @override
  ItemStore get proxyStory => _store;
}
