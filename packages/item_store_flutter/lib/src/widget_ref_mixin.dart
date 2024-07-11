import 'package:flutter/widgets.dart';
import 'package:item_store_flutter/src/context_extensions.dart';
import 'package:item_store_flutter/src/widget_ref.dart';

mixin WidgetRefMixin<T extends StatefulWidget> on State<T> {
  late final WidgetRef _ref = WidgetRef(store: context.readStore);

  WidgetRef get ref => _ref;

  bool _firstBuild = true;

  @override
  void didChangeDependencies() {
    if (_firstBuild) {
      // listen for item store changes
      context.store;
      _firstBuild = false;
    } else {
      // ignore: invalid_use_of_protected_member
      _ref.updateStore(context.store);
    }
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
