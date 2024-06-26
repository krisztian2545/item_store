import 'package:flutter/widgets.dart';
import 'package:item_store_flutter/src/reactive_listenable/reactive_listenable.dart';

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
