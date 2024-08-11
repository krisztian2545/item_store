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
      bool disposed = false;
      final factory = (Ref ref) {
        ref.onDispose(() => disposed = true);
        return 42;
      };
      store.create(factory, globalKey: key);
      store.disposeItem(key);

      expect(disposed, true);
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

  group('Create and read value', () {
    initStore() => ItemStore();

    test('createValue', () {
      final store = initStore();
      final person = Person("Jack");
      final animal = Animal("Bob");
      final taggedPerson = Person("Joe");
      final taggedAnimal = Animal("Jack");

      final retrievedPerson = store.createValue(person);
      final retrievedAnimal = store.createValue(animal);
      final retrievedTaggedPerson = store.createValue(taggedPerson, tag: "tag");
      final retrievedTaggedAnimal = store.createValue(taggedAnimal, tag: "tag");

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

      store.createValue(person);
      final retrievedPerson = store.readValue<Person>();

      store.createValue(animal);
      final retrievedAnimal = store.readValue<Animal>();

      store.createValue(taggedPerson, tag: "tag");
      final retrievedTaggedPerson = store.readValue<Person>("tag");

      store.createValue(taggedAnimal, tag: "tag");
      final retrievedTaggedAnimal = store.readValue<Animal>("tag");

      expect(retrievedPerson, person);
      expect(retrievedAnimal, animal);
      expect(retrievedTaggedPerson, taggedPerson);
      expect(retrievedTaggedAnimal, taggedAnimal);
    });
  });
}
