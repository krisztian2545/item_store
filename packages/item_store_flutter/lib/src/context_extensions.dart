import 'package:flutter/widgets.dart';
import 'package:item_store/item_store.dart';
import 'package:item_store_flutter/src/inherited_item_store.dart';

extension ItemStoreFlutterExtension on BuildContext {
  /// Get [ItemStore] from context and depend on changes.
  ItemStore get store => InheritedItemStore.of(this);

  /// Get [ItemStore] from context without depending on changes.
  ItemStore get readStore => InheritedItemStore.of(this, listen: false);
}
