import 'package:flutter/widgets.dart';
import 'package:item_store_flutter/item_store_flutter.dart';

class ItemBuilder extends ItemConsumer {
  const ItemBuilder({
    super.key,
    required this.builder,
    this.child,
  });

  final Widget? child;
  final Widget Function(BuildContext, WidgetRef, Widget?) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return builder(context, ref, child);
  }
}
