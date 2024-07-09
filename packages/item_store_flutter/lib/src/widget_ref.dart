import 'package:item_store/item_store.dart';

extension type WidgetRef(Ref _ref) {
  /// An [ItemStore] exclusive to this [Ref], so you can reuse factory functions
  /// to create local data.
  ///
  /// It also adds a convenience call method for [ItemStoreUtilX.get] to reduce
  /// boilerplate.
  LocalItemStore get local => _ref.local; // = LocalItemStore(ItemStore());

  // final ItemMetaData _itemMetaData = ItemMetaData();

  T call<T>(ItemFactory<T> itemFactory, {Object? globalKey, Object? tag}) =>
      _ref<T>(itemFactory, globalKey: globalKey, tag: tag);

  T create<T>(ItemFactory<T> itemFactory, {Object? globalKey, Object? tag}) {
    return _ref.create(itemFactory, globalKey: globalKey, tag: tag);
  }

  T read<T>(Object globalKey) => _ref.read(globalKey);

  void disposeSelf() => _store.disposeItem(itemKey);

  /// Adds [callback] to the list of dispose callbacks.
  void onDispose(ItemDisposeCallback callback) {
    _itemMetaData.disposeCallbacks.add(callback);
  }

  void removeDisposeCallback(ItemDisposeCallback callback) {
    _itemMetaData.disposeCallbacks.remove(callback);
  }
}
