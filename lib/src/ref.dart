import 'package:item_store/item_store.dart';

class Ref<IS extends ItemStore, LocalIS extends ItemStore> with ProxyItemsApi<IS> {
  /// Creates Ref without having to initialize the globalKey, tag and args
  /// in the constructor.
  /// You must call [init] later, before passing it to the actual item factory!
  Ref({
    required IS store,
    required this.key,
    CallableItemStore<LocalIS>? localStore,
    ItemMetaData? itemMetaData,
  })  : assert(localStore != null || (LocalIS == ItemStore || LocalIS == DefaultItemStoreType)),
        _store = store,
        _local = localStore,
        itemMetaData = itemMetaData ?? ItemMetaData();

  final IS _store;

  CallableItemStore<LocalIS>? _local;

  /// An [ItemStore] exclusive to this [Ref], so you can reuse factory functions
  /// to create local data.
  ///
  /// It also adds a convenience call method for [ItemStore.get] to reduce
  /// boilerplate.
  CallableItemStore<LocalIS> get local => _lazyLocal();

  CallableItemStore<LocalIS> _getLocal() => _local!;
  late CallableItemStore<LocalIS> Function() _lazyLocal = () {
    _local ??= CallableItemStore(ItemStore() as LocalIS);
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
  IS get proxiedStore => _store;
}
