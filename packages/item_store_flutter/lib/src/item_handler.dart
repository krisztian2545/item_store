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

  /// Initialize store items here.
  /// It's called inside the [State.didChangeDependencies] method.
  final void Function(ItemStore)? init;

  /// A list of global keys of items, that you want to dispose
  /// when this widget gets disposed.
  final List<Object>? disposables;

  @override
  State<ItemHandler> createState() => _ItemHandlerState();
}

class _ItemHandlerState extends State<ItemHandler> {
  late ItemStore _store;

  late void Function() _onDidChangeDependencies = _onFirstCallToDidChangeDeps;

  void _onFirstCallToDidChangeDeps() {
    // Items are not disposed on first build to let you decide whether to reuse
    // an item from the inherited store.

    // listen to inherited store and call widget.init
    _getStoreAndInit();

    // run the other function on consequent dependency change calls
    _onDidChangeDependencies = _onConsequentCallsToDidChangeDeps;
  }

  void _onConsequentCallsToDidChangeDeps() {
    // dispose items in the old store
    _disposeItems(widget.disposables);

    // listen to new inherited store and recall widget.init
    _getStoreAndInit();
  }

  void _getStoreAndInit() {
    _store = context.store;
    widget.init?.call(_store);
  }

  @override
  void didChangeDependencies() {
    _onDidChangeDependencies();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant ItemHandler oldWidget) {
    if (oldWidget.init != widget.init) {
      widget.init?.call(_store);
    }

    // prevent memory leaks
    final leaks = oldWidget.disposables?.where(
      (d) => !(widget.disposables?.contains(d) ?? false),
    );
    _disposeItems(leaks);

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder?.call(context, widget.child) ?? widget.child!;
  }

  void _disposeItems(Iterable<Object>? disposables) {
    if (disposables?.isNotEmpty ?? false) {
      _store.disposeItems(disposables!);
    }
  }

  @override
  void dispose() {
    _disposeItems(widget.disposables);
    super.dispose();
  }
}
