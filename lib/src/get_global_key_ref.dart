part of 'item_store.dart';

/// For internal use only.
class _GetGlobalKeyRef implements Ref {
  @override
  Object? _globalKey;
  @override
  Object get globalKey {
    if (!isInitialized) {
      throw UninitializedException(
          'globalKey was not initialized. You probably just forgot to wrap the factory with ".p()"');
    }

    return _globalKey!;
  }

  @override
  bool _isInitialized = false;
  @override
  bool get isInitialized => _isInitialized;

  @override
  void init({
    required Function itemFactory,
    Object? args,
  }) {
    _globalKey ??=
        ItemStore.globalKeyFrom(itemFactory: itemFactory, args: args);
    _isInitialized = true;

    throw OverriddenException();
  }

  @override
  Object? _args;

  @override
  bool get _checkKeyInStore => throw UnimplementedError();

  @override
  ItemStore get _store => throw UnimplementedError();

  @override
  Object? get args => throw UnimplementedError();

  @override
  T call<T>(
    ItemFactory<T> itemFactory, {
    Object? globalKey,
    Object? tag,
    List<Object>? dependencies,
  }) {
    throw UnimplementedError();
  }

  @override
  void disposeSelf() {
    throw UnimplementedError();
  }

  @override
  bool get isOverridden => throw UnimplementedError();

  @override
  ItemMetaData get itemMetaData => throw UnimplementedError();

  @override
  CallableItemStore get local => throw UnimplementedError();

  @override
  void onDispose(ItemDisposeCallback callback) {
    throw UnimplementedError();
  }

  @override
  T? read<T>(ItemFactory<T> itemFactory, {Object? tag}) {
    throw UnimplementedError();
  }

  @override
  T? readByKey<T>(Object globalKey) {
    throw UnimplementedError();
  }

  @override
  T? readValue<T>([Object? tag]) {
    throw UnimplementedError();
  }

  @override
  void removeDisposeCallback(ItemDisposeCallback callback) {
    throw UnimplementedError();
  }

  @override
  T write<T>(ItemFactory<T> itemFactory, {Object? globalKey, Object? tag}) {
    throw UnimplementedError();
  }

  @override
  T writeValue<T>(
    T value, {
    Object? tag,
    bool disposable = false,
    void Function(T)? dispose,
  }) {
    throw UnimplementedError();
  }

  @override
  void overrideFactory<T>(ItemFactory<T> from, ItemFactory<T> to) {
    throw UnimplementedError();
  }

  @override
  void remove<T>(ItemFactory<T> itemFactory) {
    throw UnimplementedError();
  }

  @override
  void removeItem(Object globalKey) {
    throw UnimplementedError();
  }

  @override
  void removeItems(Iterable<Object> globalKeys) {
    throw UnimplementedError();
  }

  @override
  void removeOverrideFrom(ItemFactory factory) {
    throw UnimplementedError();
  }

  @override
  void removeValue<T>([Object? tag]) {
    throw UnimplementedError();
  }

  @override
  T run<T>(ItemFactory<T> itemFactory) {
    throw UnimplementedError();
  }
}
