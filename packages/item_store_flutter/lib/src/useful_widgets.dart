import 'package:flutter/widgets.dart';
import 'package:item_store_flutter/item_store_flutter.dart';

class ItemsHandler extends StatefulWidget {
  const ItemsHandler({
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

class NotifierBuilder extends StatefulWidget {
  const NotifierBuilder({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext, WatchFunction) builder;

  @override
  State<NotifierBuilder> createState() => _NotifierBuilderState();
}

class _NotifierBuilderState extends State<NotifierBuilder> {
  final _listenables = <Listenable>[];
  Listenable? _combinedListenable;

  void _handleChange() => setState(() {});

  T watch<T extends Listenable>(T listenable) {
    if (!_listenables.contains(listenable)) {
      _listenables.add(listenable);
    }
    return listenable;
  }

  @override
  Widget build(BuildContext context) {
    _clearListenables();

    final buildedWidget = widget.builder(context, watch);

    _combinedListenable = Listenable.merge(_listenables);
    _combinedListenable?.addListener(_handleChange);

    return buildedWidget;
  }

  void _clearListenables() {
    _combinedListenable?.removeListener(_handleChange);
    _listenables.clear();
  }

  @override
  void dispose() {
    _clearListenables();
    super.dispose();
  }
}
