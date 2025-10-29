import 'package:flutter/widgets.dart';
import 'package:item_store/item_store.dart';
import 'package:item_store_flutter/src/context_extensions.dart';
import 'package:item_store_flutter/src/widget_ref.dart';

mixin CustomWidgetRefMixin<T extends StatefulWidget> on State<T> {
  // TODO what if the implementation doesn't always return the same store?
  ItemStore get store;

  late final WidgetRef _ref = WidgetRef(store: store)..local.writeValue(context);

  WidgetRef get ref => _ref;

  @override
  @protected
  @mustCallSuper
  void dispose() {
    // ignore: invalid_use_of_protected_member
    _ref.dispose();
    super.dispose();
  }
}

mixin WidgetRefMixin<T extends StatefulWidget> on State<T> {
  late final WidgetRef _ref = WidgetRef(store: context.readStore)..local.writeValue(context);

  WidgetRef get ref => _ref;

  @override
  void didChangeDependencies() {
    // ignore: invalid_use_of_protected_member
    _ref.updateStore(context.store);
    super.didChangeDependencies();
  }

  @override
  @protected
  @mustCallSuper
  void dispose() {
    // ignore: invalid_use_of_protected_member
    _ref.dispose();
    super.dispose();
  }
}
