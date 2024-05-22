import 'package:item_store/item_store.dart';
import 'package:provider/provider.dart';

class ItemStoreProvider extends Provider<ItemStore> {
  ItemStoreProvider({
    super.key,
    super.child,
    super.lazy,
    super.builder,
  }) : super(
          create: (_) => ItemStore(),
          dispose: (context, store) => store.dispose(),
        );

  ItemStoreProvider.value({
    super.key,
    required super.value,
    super.child,
    super.builder,
    super.updateShouldNotify,
  }) : super.value();
}
