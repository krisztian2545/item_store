import 'package:flutter/widgets.dart';
import 'package:item_store/item_store.dart';
import 'package:item_store_flutter/src/context_extensions.dart';

mixin WidgetRefMixin<T extends StatefulWidget> on State<T> {
  late final Ref ref;

  @override
  @protected
  @mustCallSuper
  void initState() {
    // TODO handle when parent ItemStore changes
    ref = Ref(store: context.store, itemKey: UniqueKey());
    super.initState();
  }

  @override
  @protected
  @mustCallSuper
  void dispose() {
    ref.disposeSelf();
    super.dispose();
  }
}
