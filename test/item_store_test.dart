import 'package:item_store/item_store.dart';
import 'package:test/test.dart';

class CustomKey {}

class OtherCustomKey {}

class Person {
  Person(this.name);
  final String name;
}

class Animal {
  Animal(this.name);
  final String name;
}

void main() {
  (ItemStore, String, int Function(Ref)) initialVariables() => (ItemStore(), 'key', (_) => 42);

  group('ItemStore', () {
    test('write', () {
      final (store, _, itemFactory) = initialVariables();
      final item = store.write(itemFactory);
      expect(item, 42);
    });

    test('write with global key', () {
      final (store, key, itemFactory) = initialVariables();
      final item = store.write(itemFactory, key: key);
      expect(item, 42);
    });

    test('read', () {
      final (store, _, itemFactory) = initialVariables();
      store.write(itemFactory);
      expect(store.read(itemFactory), 42);
    });

    test('readByKey', () {
      final (store, key, itemFactory) = initialVariables();
      store.write(itemFactory, key: key);
      expect(store.readByKey(key), 42);
    });

    test('get with globalKey multiple times', () {
      final (store, key, itemFactory) = initialVariables();
      int otherFactory(Ref _) => 0;

      expect(store.get<int>(itemFactory, key: key), 42);
      expect(store.get<int>(otherFactory, key: key), 42);
    });

    group('Ref', () {
      test('onDispose', () {
        final (store, key, _) = initialVariables();
        bool disposed = false;
        itemFactory(Ref ref) {
          ref.onDispose(() => disposed = true);
          return 42;
        }

        store.write(itemFactory, key: key);
        store.disposeItem(key);

        expect(disposed, true);
      });
    });

    group('Type as key', () {
      (ItemStore, Type) initStoreAndTypeKey() => (ItemStore(), CustomKey);

      test('write', () {
        final (store, key) = initStoreAndTypeKey();
        final Type otherKey = OtherCustomKey;

        final item = store.write(((_) => 42), key: key);
        final otherItem = store.write(((_) => 'other'), key: otherKey);

        expect(item, 42);
        expect(otherItem, 'other');
      });

      test('read', () {
        final (store, key) = initStoreAndTypeKey();
        final Type otherKey = OtherCustomKey;

        store.write(((_) => 42), key: key);
        store.write(((_) => 'other'), key: otherKey);

        expect(store.readByKey(key), 42);
        expect(store.readByKey(otherKey), 'other');
      });

      test('get', () {
        final (store, key) = initStoreAndTypeKey();
        final Type otherKey = OtherCustomKey;

        expect(store.get(((_) => 42), key: key), 42);
        expect(store.get(((_) => 'other'), key: otherKey), 'other');
      });
    });

    group('Write and read value', () {
      initStore() => ItemStore();

      test('createValue', () {
        final store = initStore();
        final person = Person("Jack");
        final animal = Animal("Bob");
        final taggedPerson = Person("Joe");
        final taggedAnimal = Animal("Jack");

        final retrievedPerson = store.writeValue(person);
        final retrievedAnimal = store.writeValue(animal);
        final retrievedTaggedPerson = store.writeValue(taggedPerson, tag: "tag");
        final retrievedTaggedAnimal = store.writeValue(taggedAnimal, tag: "tag");

        expect(retrievedPerson, person);
        expect(retrievedAnimal, animal);
        expect(retrievedTaggedPerson, taggedPerson);
        expect(retrievedTaggedAnimal, taggedAnimal);
      });

      test('readValue', () {
        final store = initStore();
        final person = Person("Jack");
        final animal = Animal("Bob");
        final taggedPerson = Person("Joe");
        final taggedAnimal = Animal("Jack");

        store.writeValue(person);
        final retrievedPerson = store.readValue<Person>();

        store.writeValue(animal);
        final retrievedAnimal = store.readValue<Animal>();

        store.writeValue(taggedPerson, tag: "tag");
        final retrievedTaggedPerson = store.readValue<Person>("tag");

        store.writeValue(taggedAnimal, tag: "tag");
        final retrievedTaggedAnimal = store.readValue<Animal>("tag");

        expect(retrievedPerson, person);
        expect(retrievedAnimal, animal);
        expect(retrievedTaggedPerson, taggedPerson);
        expect(retrievedTaggedAnimal, taggedAnimal);
      });
    });

    group('Dependencies', () {
      test('dependOnIfExists should set up disposal chain when item exists', () {
        final store = ItemStore();
        store.write((ref) => 'dependency', key: 'dependency');
        store.write(key: 'item', (ref) {
          ref.dependOnIfExists('dependency');
          return 'item';
        });

        expect(store.contains('dependency'), true);
        expect(store.contains('item'), true);

        store.disposeItem('dependency');

        expect(store.contains('dependency'), false);
        expect(store.contains('item'), false);
      });

      test('dependOnIfExists should do nothing when item does not exist', () {
        final store = ItemStore();
        store.write(key: 'item', (ref) {
          ref.dependOnIfExists('dependency');
          return 'item';
        });

        expect(store.contains('dependency'), false);
        expect(store.contains('item'), true);

        store.disposeItem('dependency');

        expect(store.contains('dependency'), false);
        expect(store.contains('item'), true);
      });

      test("readDepByKey should return the item's data and set up dependency", () {
        final store = ItemStore();
        store.write((ref) => 'dependency', key: 'dependency');
        final item = store.write(key: 'item', (ref) => '${ref.readDepByKey('dependency')} in item');

        expect(store.contains('dependency'), true);
        expect(store.contains('item'), true);
        expect(item, 'dependency in item');

        store.disposeItem('dependency');

        expect(store.contains('dependency'), false);
        expect(store.contains('item'), false);
      });

      test(
        'readDepByKey should return null and not set up dependency when item does not exist',
        () {
          final store = ItemStore();
          final item = store.write(
            key: 'item',
            (ref) => '${ref.readDepByKey('dependency')} in item',
          );

          expect(store.contains('dependency'), false);
          expect(store.contains('item'), true);
          expect(item, 'null in item');

          store.disposeItem('dependency');

          expect(store.contains('dependency'), false);
          expect(store.contains('item'), true);
        },
      );

      test("readDep should return the item's data and set up dependency", () {
        final store = ItemStore();
        String dependency(Ref ref) => 'dependency';
        store.write(dependency);
        final item = store.write(key: 'item', (ref) => '${ref.readDep(dependency)} in item');

        expect(store.contains(dependency), true);
        expect(store.contains('item'), true);
        expect(item, 'dependency in item');

        store.disposeItem(dependency);

        expect(store.contains(dependency), false);
        expect(store.contains('item'), false);
      });

      test('readDep should return null and not set up dependency when item does not exist', () {
        final store = ItemStore();
        String dependency(Ref ref) => 'dependency';
        final item = store.write(key: 'item', (ref) => '${ref.readDep(dependency)} in item');

        expect(store.contains(dependency), false);
        expect(store.contains('item'), true);
        expect(item, 'null in item');

        store.disposeItem(dependency);

        expect(store.contains(dependency), false);
        expect(store.contains('item'), true);
      });

      test("writeDep should return the item's data and set up dependency", () {
        final store = ItemStore();
        String dependency(Ref ref) => 'dependency';

        expect(store.contains(dependency), false);

        final item = store.write(key: 'item', (ref) => '${ref.writeDep(dependency)} in item');

        expect(store.contains(dependency), true);
        expect(store.contains('item'), true);
        expect(item, 'dependency in item');

        store.disposeItem(dependency);

        expect(store.contains(dependency), false);
        expect(store.contains('item'), false);
      });

      test("getDep should return the item's data and set up dependency", () {
        final store = ItemStore();
        String dependency(Ref ref) => 'dependency';

        expect(store.contains(dependency), false);

        final item = store.write(key: 'item', (ref) => '${ref.getDep(dependency)} in item');

        expect(store.contains(dependency), true);
        expect(store.contains('item'), true);
        expect(item, 'dependency in item');

        store.disposeItem(dependency);

        expect(store.contains(dependency), false);
        expect(store.contains('item'), false);
      });

      test("dep should return the item's data and set up dependency", () {
        final store = ItemStore();
        String dependency(Ref ref) => 'dependency';

        expect(store.contains(dependency), false);

        final item = store.write(key: 'item', (ref) => '${ref.dep(dependency)} in item');

        expect(store.contains(dependency), true);
        expect(store.contains('item'), true);
        expect(item, 'dependency in item');

        store.disposeItem(dependency);

        expect(store.contains(dependency), false);
        expect(store.contains('item'), false);
      });
    });
  });
}
