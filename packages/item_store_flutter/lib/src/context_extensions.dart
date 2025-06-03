import 'package:flutter/widgets.dart';
import 'package:item_store/item_store.dart';
import 'package:item_store_flutter/src/inherited_item_store.dart';

extension ItemStoreFlutterExtension on BuildContext {
  /// Get [ItemStore] from context and depend on changes.
  ItemStore get store => InheritedItemStore.of(this);

  /// Get [ItemStore] from context without depending on changes.
  ItemStore get readStore => InheritedItemStore.of(this, listen: false);
}

extension ItemStoreFlutterShortcutsExtension on BuildContext {
  T? readByKey<T>(Object key) => store.readByKey<T>(key);

  T write<T>(ItemFactory<T> itemFactory, {Object? key}) {
    return store.write<T>(itemFactory, key: key);
  }

  T? read<T>(ItemFactory<T> itemFactory, {Object? key}) =>
      store.read<T>(itemFactory, key: key);

  T get<T>(ItemFactory<T> itemFactory, {Object? key}) {
    return store.get<T>(itemFactory, key: key);
  }

  T run<T>(ItemFactory<T> itemFactory) {
    return store.run<T>(itemFactory);
  }

  T writeValue<T>(
    T value, {
    Object? tag,
    bool disposable = false,
    void Function(T)? dispose,
  }) {
    return store.writeValue<T>(
      value,
      tag: tag,
      disposable: disposable,
      dispose: dispose,
    );
  }

  T? readValue<T>([Object? tag]) => store.readValue<T>(tag);
}
