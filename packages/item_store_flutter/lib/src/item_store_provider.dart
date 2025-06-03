import 'package:flutter/widgets.dart';
import 'package:item_store/item_store.dart';
import 'package:item_store_flutter/src/inherited_item_store.dart';

typedef ItemStoreDisposeBehaviorCallback = void Function(
    ItemStoreProvider widget, ItemStore store);

abstract class ItemStoreProviderDisposeBehavior {
  const ItemStoreProviderDisposeBehavior();
  void dispose(ItemStoreProvider widget, ItemStore store);
}

class ItemStoreDisposeBehavior extends ItemStoreProviderDisposeBehavior {
  const ItemStoreDisposeBehavior.from(this.callback);

  final void Function(ItemStoreProvider widget, ItemStore store) callback;

  @override
  void dispose(ItemStoreProvider widget, ItemStore store) =>
      callback(widget, store);
}

class AlwaysDisposeItemStore extends ItemStoreProviderDisposeBehavior {
  const AlwaysDisposeItemStore();
  @override
  void dispose(ItemStoreProvider widget, ItemStore store) {
    store.dispose();
  }
}

class DoNotDisposeGivenItemStore extends ItemStoreProviderDisposeBehavior {
  const DoNotDisposeGivenItemStore();
  @override
  void dispose(ItemStoreProvider widget, ItemStore store) {
    // dispose store if it wasn't injected from outside
    if (widget.store == null) {
      store.dispose();
    }
  }
}

class ItemStoreProvider extends StatefulWidget {
  const ItemStoreProvider({
    super.key,
    this.child,
    this.builder,
    this.disposeBehavior = const DoNotDisposeGivenItemStore(),
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
    this.disposeBehavior = const DoNotDisposeGivenItemStore(),
  }) : assert(
          child != null || builder != null,
          "Either child or builder must be given.",
        );

  final ItemStore? store;

  final Widget? child;
  final Widget Function(BuildContext, Widget?)? builder;

  final ItemStoreProviderDisposeBehavior disposeBehavior;

  @override
  State<ItemStoreProvider> createState() => _ItemStoreProviderState();
}

class _ItemStoreProviderState extends State<ItemStoreProvider> {
  late ItemStore _store = _getStore();

  ItemStore _getStore() => widget.store ?? ItemStore();

  @override
  void didUpdateWidget(covariant ItemStoreProvider oldWidget) {
    if (oldWidget.store != widget.store) {
      oldWidget.disposeBehavior.dispose(oldWidget, _store);
      _store = _getStore();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.disposeBehavior.dispose(widget, _store);
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
