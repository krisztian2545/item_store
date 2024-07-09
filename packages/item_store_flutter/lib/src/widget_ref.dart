import 'package:flutter/widgets.dart';
import 'package:item_store/item_store.dart';

class WidgetRef with DisposableMixin {
  WidgetRef({
    required ItemStore store,
    LocalItemStore? localStore,
  })  : _store = store,
        local = localStore ?? LocalItemStore(ItemStore());

  ItemStore _store;

  @protected
  void updateStore(ItemStore newStore) => _store = newStore;

  /// An [ItemStore] exclusive to this [Ref], so you can reuse factory functions
  /// to create local data.
  ///
  /// It also adds a convenience call method for [ItemStoreUtilX.get] to reduce
  /// boilerplate.
  final LocalItemStore local;

  T call<T>(ItemFactory<T> itemFactory, {Object? globalKey, Object? tag}) =>
      _store.get<T>(itemFactory, globalKey: globalKey, tag: tag);

  T create<T>(ItemFactory<T> itemFactory, {Object? globalKey, Object? tag}) {
    return _store.create(itemFactory, globalKey: globalKey, tag: tag);
  }

  T read<T>(Object globalKey) => _store.read(globalKey);

  @protected
  @override
  void dispose() {
    super.dispose();
  }
}
