import 'package:flutter/widgets.dart';
import 'package:item_store/item_store.dart';
import 'package:item_store_flutter/src/context_extensions.dart';

mixin WidgetRefMixin<T extends StatefulWidget> on State<T> {
  late Ref _ref;
  Ref get ref => _ref;

  @override
  @protected
  @mustCallSuper
  void initState() {
    _ref = Ref(store: context.store, itemKey: UniqueKey());
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO handle when parent ItemStore changes
    _ref = Ref(
      store: context.store,
      itemKey: _ref.itemKey,
      localStore: _ref.local,
    );
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
