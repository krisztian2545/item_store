import 'package:flutter/widgets.dart';
import 'package:item_store/item_store.dart';

class WidgetRef {
  WidgetRef({
    required ItemStore store,
    CallableItemStore? localStore,
  })  : _store = store,
        _local = localStore;

  ItemStore _store;

  @protected
  void updateStore(ItemStore newStore) => _store = newStore;

  /// An [ItemStore] exclusive to this [Ref], so you can reuse factory functions
  /// to create local data.
  ///
  /// It also adds a convenience call method for [ItemStoreUtilX.get] to reduce
  /// boilerplate.
  CallableItemStore? _local;

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

  final _item = Item(null, ItemMetaData());
  ItemMetaData get _metaData => _item.metaData;

  void onDispose(void Function() callback) {
    _metaData.safeAddDisposeCallback(callback);
  }

  void removeDisposeCallback(void Function() callback) {
    _metaData.disposeCallbacks.remove(callback);
  }

  /// Calls all the dispose callbacks registered for this [WidgetRef],
  /// and disposes the [local] store.
  void dispose() {
    _item.dispose();
  }

  // ------------------------- [Ref] API -------------------------

  T run<T>(ItemFactory<T> itemFactory) {
    return _store.run<T>(itemFactory);
  }

  T call<T>(ItemFactory<T> itemFactory, {Object? key}) {
    return _store.get<T>(itemFactory, key: key);
  }

  T get<T>(ItemFactory<T> itemFactory, {Object? key}) {
    return _store.get<T>(itemFactory, key: key);
  }

  T write<T>(ItemFactory<T> itemFactory, {Object? key}) {
    return _store.write<T>(itemFactory, key: key);
  }

  T? read<T>(ItemFactory<T> itemFactory, {Object? key}) {
    return _store.read<T>(itemFactory, key: key);
  }

  T? readByKey<T>(Object key) => _store.readByKey<T>(key);

  T? readValue<T>([Object? tag]) => _store.readValue<T>(tag);

  T writeValue<T>(
    T value, {
    Object? tag,
    bool disposable = false,
    void Function(T)? dispose,
  }) {
    return _store.writeValue<T>(
      value,
      tag: tag,
      disposable: disposable,
      dispose: dispose,
    );
  }

  void disposeValue<T>([Object? tag]) {
    _store.disposeValue<T>(tag);
  }

  void overrideFactory<T>(ItemFactory<T> from, ItemFactory<T> to) {
    _store.overrideFactory<T>(from, to);
  }

  void removeOverrideFrom(ItemFactory factory) {
    _store.removeOverrideFrom(factory);
  }

  void disposeItem(Object key) {
    _store.disposeItem(key);
  }

  void disposeItems(Iterable<Object> keys) {
    _store.disposeItems(keys);
  }
}

extension WidgetRefX on WidgetRef {
  /// Binds the provided [object] to the [onDispose] callback, allowing it to be
  /// disposed when the widget gets disposed.
  ///
  /// The [object] either has to have a void dispose() function, or
  /// provide a custom [dispose] function that will be called instead.
  ///
  /// Returns the provided [object].
  ///
  /// It's safe to call this in a widget's build function, because it checks
  /// if [object] has already been registered for disposal.
  T disposable<T extends Object>(T object, [void Function(T)? dispose]) {
    return _metaData.safeAddDisposableObject(object, dispose);
  }

  void callOnce(Function() oneOffFun, {Object? tag}) {
    local((_) => oneOffFun(), key: (callOnce, tag));
  }
}

extension ObjectUtilsForWidgetRefX<T extends Object> on T {
  T disposeWithWidget(WidgetRef ref, [void Function(T)? dispose]) =>
      ref.disposable(this, dispose);
}
