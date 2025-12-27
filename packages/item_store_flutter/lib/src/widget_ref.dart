import 'package:flutter/widgets.dart';
import 'package:item_store/item_store.dart';

class WidgetRef<IS extends ItemStore, LocalIS extends ItemStore>
    with ProxyItemsApi<IS>
    implements Ref<IS, LocalIS> {
  WidgetRef({required IS store, CallableItemStore<LocalIS>? localStore, ItemMetaData? itemMetaData})
    : _store = store,
      _local = localStore,
      itemMetaData = itemMetaData ?? ItemMetaData() {
    _item = Item(null, this);
  }

  IS _store;

  @override
  IS get proxiedStore => _store;

  @protected
  void updateStore(IS newStore) => _store = newStore;

  CallableItemStore<LocalIS>? _local;

  /// An [ItemStore] exclusive to this [Ref], so you can reuse factory functions
  /// to create local data.
  ///
  /// It also adds a convenience call method for [ItemStore.get] to reduce
  /// boilerplate.
  @override
  CallableItemStore<LocalIS> get local => _lazyLocal();

  CallableItemStore<LocalIS> _getLocal() => _local!;
  late CallableItemStore<LocalIS> Function() _lazyLocal = () {
    _local ??= CallableItemStore(ItemStore() as LocalIS);
    _lazyLocal = _getLocal;
    return _local!;
  };

  late final Item _item;

  @override
  void disposeSelf() {
    throw UnsupportedError(
      "Since a widget ref's item is not stored in the store, it can't be disposed manually. It will be disposed with the widget.",
    );
  }

  /// Calls all the dispose callbacks registered for this [WidgetRef],
  /// and disposes the [local] store.
  @protected
  void dispose() {
    _item.dispose();
  }

  @override
  Object get key => throw UnsupportedError(
    "Since a widget ref's item is not stored in the store, it doesn't have a key.",
  );

  @override
  final ItemMetaData itemMetaData;

  @override
  void onDispose(ItemDisposeCallback callback) {
    itemMetaData.addDisposeCallback(callback);
  }

  @override
  void removeDisposableObject(Object object) {
    itemMetaData.removeDisposableObject(object);
  }

  @override
  void removeDisposeCallback(ItemDisposeCallback callback) {
    itemMetaData.removeDisposeCallback(callback);
  }
}

extension DependencyWidgetRefExtension<R extends Ref> on R {
  void dependOnItem(Item item) {
    if (this is WidgetRef) {
      late final void Function() cleanUpDependency;
      void safeDisposeSelf() {
        removeDisposeCallback(cleanUpDependency);
        // rebuild widget
        final element = local.readValue<BuildContext>() as Element;
        if (!element.mounted) return;
        element.markNeedsBuild();
      }

      cleanUpDependency = () {
        item.ref.removeDisposeCallback(safeDisposeSelf);
      };

      item.ref.onDispose(safeDisposeSelf);
      onDispose(cleanUpDependency);

      return;
    }

    DependencyRefExtension(this).dependOnItem(item);
  }

  void dependOnIfExistsInStore(Object key, {required ItemStore store}) {
    if (!store.contains(key)) return;

    dependOnItem(store.readItem(key)!);
  }

  void dependOn(Object key) {
    readItem(key)!.ref.onDispose(disposeSelf);
  }

  void dependOnIfExists(Object key) {
    if (!proxiedStore.contains(key)) return;

    dependOn(key);
  }

  T? readDepByKey<T>(Object key) {
    if (!proxiedStore.contains(key)) return null;

    dependOn(key);
    return proxiedStore.readByKey<T>(
      key,
    ); // we have to get the data trough the read function to allow overriding (Probabaly should make a default implementation with mustCallSuper)
  }

  T? readDep<T>(ItemFactory<T> itemFactory, {Object? key}) {
    final realKey = ItemStore.keyFrom(itemFactory, key);
    if (!proxiedStore.contains(realKey)) return null;

    dependOn(realKey);
    return proxiedStore.read<T>(itemFactory, key: key);
  }

  T writeDep<T>(ItemFactory<T> itemFactory, {Object? key}) {
    final result = proxiedStore.write<T>(itemFactory, key: key);
    dependOn(ItemStore.keyFrom(itemFactory, key));
    return result;
  }

  T getDep<T>(ItemFactory<T> itemFactory, {Object? key}) {
    final result = proxiedStore.get<T>(itemFactory, key: key);
    dependOn(ItemStore.keyFrom(itemFactory, key));
    return result;
  }

  T dep<T>(ItemFactory<T> itemFactory, {Object? key}) {
    final result = proxiedStore.get<T>(itemFactory, key: key);
    dependOn(ItemStore.keyFrom(itemFactory, key));
    return result;
  }
}

extension ObjectUtilsForWidgetRefX<T extends Object> on T {
  T disposeWithWidget(WidgetRef ref, [void Function(T)? dispose]) => ref.disposable(this, dispose);
}
