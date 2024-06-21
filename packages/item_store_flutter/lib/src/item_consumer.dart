import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:item_store/item_store.dart';
import 'package:item_store_flutter/src/widget_ref_mixin.dart';

abstract class ItemConsumer extends StatefulWidget {
  const ItemConsumer({super.key});

  Widget build(BuildContext context, Ref ref);

  @override
  State<ItemConsumer> createState() => _ItemConsumerState();
}

class _ItemConsumerState extends State<ItemConsumer> with WidgetRefMixin {
  @override
  Widget build(BuildContext context) {
    return widget.build(context, ref);
  }
}
