import 'package:flutter/widgets.dart';
import 'package:item_store/item_store.dart';
import 'package:item_store_flutter/src/context_extensions.dart';
import 'package:item_store_flutter/src/widget_ref.dart';

mixin CustomWidgetRefMixin<T extends StatefulWidget> on State<T> {
  // TODO what if the implementation doesn't always return the same store?
  ItemStore get store;

  late final WidgetRef _ref = WidgetRef(store: store);

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
  late final WidgetRef _ref = WidgetRef(store: context.readStore);

  WidgetRef get ref => _ref;

  late void Function() _onDidChangeDependencies = _onFirstCallToDidChangeDeps;

  void _onFirstCallToDidChangeDeps() {
    // listen for item store changes
    context.store;

    // run the other function on consequent dependency change calls
    _onDidChangeDependencies = _onConsequentCallsToDidChangeDeps;
  }

  void _onConsequentCallsToDidChangeDeps() {
    // ignore: invalid_use_of_protected_member
    _ref.updateStore(context.store);
  }

  @override
  void didChangeDependencies() {
    _onDidChangeDependencies();
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
