import 'package:item_store/item_store.dart';
import 'package:test/test.dart';

void main() {
  group('ItemStore', () {
    (ItemStore, String) initStoreAndKey() => (ItemStore(), 'key');

    test('create', () {
      final (store, key) = initStoreAndKey();
      final item = store.create((_) => 42, globalKey: key);
      expect(item, 42);
    });

    test('read', () {
      final (store, key) = initStoreAndKey();
      store.create((_) => 42, globalKey: key);
      expect(store.read(key), 42);
    });

    test('get', () {
      final (store, key) = initStoreAndKey();
      expect(store.get<int>((_) => 42, globalKey: key), 42);
    });
  });
}
