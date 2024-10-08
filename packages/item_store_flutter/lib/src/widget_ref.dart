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

  T get<T>(
    ItemFactory<T> itemFactory, {
    Object? globalKey,
    Object? tag,
    Object? args,
  }) =>
      _store.get<T>(itemFactory, globalKey: globalKey, tag: tag, args: args);

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

  T read<T>(Object globalKey) => _store.read(globalKey);

  T? readValue<T>([Object? tag]) =>
      _store.read<T>(ItemStore.valueKeyFrom(T, tag: tag));

  T createValue<T>(T value, {Object? tag}) => _store.create<T>(
        (_) => value,
        globalKey: ItemStore.valueKeyFrom(T, tag: tag),
      );

  @protected
  @override
  void dispose() {
    super.dispose();
  }
}
