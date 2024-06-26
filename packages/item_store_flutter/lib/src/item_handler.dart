import 'package:flutter/widgets.dart';
import 'package:item_store_flutter/item_store_flutter.dart';

class ItemHandler extends StatefulWidget {
  const ItemHandler({
    super.key,
    this.child,
    this.builder,
    this.init,
    this.disposables,
  }) : assert(
          builder != null || child != null,
          'builder or child must be specified!',
        );

  final Widget? child;
  final Widget Function(BuildContext, Widget?)? builder;

  final void Function(ItemStore)? init;

  /// A list of global keys of items, that you want to dispose
  /// when this widget gets disposed.
  final List<Object>? disposables;

  @override
  State<ItemHandler> createState() => _ItemHandlerState();
}

class _ItemHandlerState extends State<ItemHandler> {
  @override
  void initState() {
    super.initState();
    widget.init?.call(context.store);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder?.call(context, widget.child) ?? widget.child!;
  }

  @override
  void dispose() {
    if (widget.disposables?.isNotEmpty ?? false) {
      context.store.disposeItems(widget.disposables!);
    }
    super.dispose();
  }
}
