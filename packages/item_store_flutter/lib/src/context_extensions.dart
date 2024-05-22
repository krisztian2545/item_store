import 'package:flutter/widgets.dart';
import 'package:item_store/item_store.dart';
import 'package:provider/provider.dart';

extension ItemStoreFlutterExtension on BuildContext {
  ItemStore get store => Provider.of<ItemStore>(this, listen: false);
}
