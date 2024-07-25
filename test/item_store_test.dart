import 'package:item_store/item_store.dart';
import 'package:test/test.dart';

class CustomKey {}

class OtherCustomKey {}

void main() {
  (ItemStore, String) initStoreAndKey() => (ItemStore(), 'key');

  group('ItemStore', () {
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

  group('Ref', () {
    test('onDispose', () {
      final (store, key) = initStoreAndKey();
      final factory = (Ref ref) {
        ref.onDispose(() => print('disposing...'));
        return 42;
      };
      store.create(factory, globalKey: key);
      store.disposeItem(key);
    });
  });

  group('Type as key', () {
    (ItemStore, Type) initStoreAndTypeKey() => (ItemStore(), CustomKey);

    test('create', () {
      final (store, key) = initStoreAndTypeKey();
      final Type otherKey = OtherCustomKey;

      final item = store.create((_) => 42, globalKey: key);
      final otherItem = store.create((_) => 'other', globalKey: otherKey);

      expect(item, 42);
      expect(otherItem, 'other');
    });

    test('read', () {
      final (store, key) = initStoreAndTypeKey();
      final Type otherKey = OtherCustomKey;

      store.create((_) => 42, globalKey: key);
      store.create((_) => 'other', globalKey: otherKey);

      expect(store.read(key), 42);
      expect(store.read(otherKey), 'other');
    });

    test('get', () {
      final (store, key) = initStoreAndTypeKey();
      final Type otherKey = OtherCustomKey;

      expect(store.get((_) => 42, globalKey: key), 42);
      expect(store.get((_) => 'other', globalKey: otherKey), 'other');
    });
  });
}
