import 'package:flutter/widgets.dart';
import 'package:item_store/item_store.dart';

class InheritedItemStore extends InheritedWidget {
  const InheritedItemStore({
    super.key,
    required super.child,
    required this.store,
  });

  final ItemStore store;

  static ItemStore? maybeOf(BuildContext context, {bool listen = true}) {
    return (listen
            ? context.dependOnInheritedWidgetOfExactType<InheritedItemStore>()
            : context.getInheritedWidgetOfExactType<InheritedItemStore>())
        ?.store;
  }

  static ItemStore of(BuildContext context, {bool listen = true}) {
    final result = maybeOf(context, listen: listen);
    assert(result != null, 'No InheritedItemStore found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(InheritedItemStore oldWidget) {
    return store != oldWidget.store;
  }
}
