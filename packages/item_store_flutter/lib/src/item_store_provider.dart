import 'package:flutter/widgets.dart';
import 'package:item_store/item_store.dart';
import 'package:item_store_flutter/src/inherited_item_store.dart';

class ItemStoreProvider extends StatefulWidget {
  const ItemStoreProvider({
    super.key,
    this.child,
    this.builder,
  })  : store = null,
        assert(
          child != null || builder != null,
          "Either child or builder must be given.",
        );

  const ItemStoreProvider.value({
    super.key,
    required ItemStore this.store,
    this.child,
    this.builder,
  }) : assert(
          child != null || builder != null,
          "Either child or builder must be given.",
        );

  final ItemStore? store;

  final Widget? child;
  final Widget Function(BuildContext, Widget?)? builder;

  @override
  State<ItemStoreProvider> createState() => _ItemStoreProviderState();
}

class _ItemStoreProviderState extends State<ItemStoreProvider> {
  late ItemStore _store = _getStore();

  ItemStore _getStore() => widget.store ?? ItemStore();

  @override
  void didUpdateWidget(covariant ItemStoreProvider oldWidget) {
    if (oldWidget.store != widget.store) {
      _store = _getStore();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    // dispose store if it wasn't injected from outside
    if (widget.store == null) {
      _store.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InheritedItemStore(
      store: _store,
      child: widget.builder?.call(context, widget.child) ?? widget.child!,
    );
  }
}
