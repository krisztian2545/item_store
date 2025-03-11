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
  final Widget Function(BuildContext, WidgetRef, Widget?)? builder;

  /// Initialize store items here.
  /// It will be called inside the [State.didChangeDependencies] method.
  final void Function(BuildContext, WidgetRef)? init;

  /// A list of global keys of items, that you want to dispose
  /// from the inherited store, when this widget gets disposed.
  final List<Object>? disposables;

  @override
  State<ItemHandler> createState() => _ItemHandlerState();
}

class _ItemHandlerState extends State<ItemHandler> with WidgetRefMixin {
  late ItemStore _store;

  late void Function() _onDidChangeDependencies = _onFirstCallToDidChangeDeps;

  void _onFirstCallToDidChangeDeps() {
    // Items are not disposed on first build to let you decide whether to reuse
    // an item from the inherited store.

    // listen to inherited store and call widget.init
    _store = context.store;
    _init();

    // run the other function on consequent dependency change calls
    _onDidChangeDependencies = _onConsequentCallsToDidChangeDeps;
  }

  void _onConsequentCallsToDidChangeDeps() {
    // dispose items in the old store
    final newStore = context.store;
    if (_store != newStore) {
      _disposeItems(_store, widget.disposables);
      _store = newStore;
    }

    // recall widget.init
    _init();
  }

  void _init() {
    widget.init?.call(context, ref);
  }

  @override
  void didChangeDependencies() {
    _onDidChangeDependencies();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant ItemHandler oldWidget) {
    if (oldWidget.init != widget.init) {
      _init();
    }

    // prevent memory leaks
    final leaks = oldWidget.disposables?.where(
      (d) => !(widget.disposables?.contains(d) ?? false),
    );
    _disposeItems(_store, leaks);

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder?.call(context, ref, widget.child) ?? widget.child!;
  }

  void _disposeItems(ItemStore store, Iterable<Object>? disposables) {
    if (disposables?.isNotEmpty ?? false) {
      store.disposeItems(disposables!);
    }
  }

  @override
  void dispose() {
    _disposeItems(_store, widget.disposables);
    super.dispose();
  }
}
