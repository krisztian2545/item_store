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
