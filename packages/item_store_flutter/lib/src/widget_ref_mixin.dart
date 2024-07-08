import 'package:flutter/widgets.dart';
import 'package:item_store/item_store.dart';
import 'package:item_store_flutter/src/context_extensions.dart';
import 'package:item_store_flutter/src/inherited_item_store.dart';

mixin WidgetRefMixin<T extends StatefulWidget> on State<T> {
  late Ref _ref;
  // TODO create a different WidgetRef
  Ref get ref => _ref;

  bool _firstBuild = true;

  @override
  @protected
  @mustCallSuper
  void initState() {
    _ref = Ref(store: context.readStore, itemKey: UniqueKey());
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_firstBuild) {
      // listen for item store changes
      context.store;
      _firstBuild = false;
    } else {
      _ref = Ref(
        store: context.store,
        itemKey: _ref.itemKey,
        localStore: _ref.local,
      );
    }
    super.didChangeDependencies();
  }

  @override
  @protected
  @mustCallSuper
  void dispose() {
    _ref.disposeSelf();
    super.dispose();
  }
}
