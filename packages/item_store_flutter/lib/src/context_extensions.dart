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
  T write<T>(
    ItemFactory<T> itemFactory, {
    Object? globalKey,
    Object? tag,
  }) {
    return store.write(
      itemFactory,
      globalKey: globalKey,
      tag: tag,
    );
  }

  T read<T>(Object globalKey) => store.readByKey(globalKey);

  T get<T>(
    ItemFactory<T> itemFactory, {
    Object? globalKey,
    Object? tag,
    List<Object>? dependencies,
  }) =>
      store.get<T>(
        itemFactory,
        globalKey: globalKey,
        tag: tag,
        dependencies: dependencies,
      );

  T writeValue<T>(T value, {Object? tag}) => store.write<T>(
        (_) => value,
        globalKey: ItemStore.valueKeyFrom(T, tag: tag),
      );

  T? readValue<T>([Object? tag]) =>
      store.readByKey<T>(ItemStore.valueKeyFrom(T, tag: tag));
}
