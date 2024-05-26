import 'package:flutter/widgets.dart';
import 'package:item_store/item_store.dart';
import 'package:item_store_flutter/item_store_flutter.dart';

class ItemsHandler extends StatefulWidget {
  const ItemsHandler({
    super.key,
    required this.child,
    this.init,
    this.disposables,
  });

  final Widget child;

  final void Function(ItemStore)? init;

  /// A list of global keys of items, that you want to dispose
  /// when this widget gets disposed.
  final List<Object>? disposables;

  @override
  State<ItemsHandler> createState() => _ItemsHandlerState();
}

class _ItemsHandlerState extends State<ItemsHandler> {
  @override
  void initState() {
    super.initState();
    widget.init?.call(context.store);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    if (widget.disposables?.isNotEmpty ?? false) {
      context.store.disposeItems(widget.disposables!);
    }
    super.dispose();
  }
}
