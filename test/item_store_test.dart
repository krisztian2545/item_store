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

    test('get with globalKey multiple times', () {
      final (store, key) = initStoreAndKey();
      expect(store.get<int>((_) => 42, globalKey: key), 42);
      expect(store.get<int>((_) => 0, globalKey: key), 42);
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

  group('ItemStore "w" syntax', () {
    test('createw', () {
      final (store, key) = initStoreAndKey();
      int sum(Ref ref, List<int> args) =>
          args.reduce((value, element) => value + element);

      final item = store.createw(sum.w([2, 20, 6, 14]), globalKey: key);

      expect(item, 42);
    });

    test('read', () {
      final (store, key) = initStoreAndKey();
      int sum(Ref ref, List<int> args) =>
          args.reduce((value, element) => value + element);

      store.createw(sum.w([2, 20, 6, 14]), globalKey: key);

      expect(store.read(key), 42);
    });

    test('getw by globalKey', () {
      final (store, key) = initStoreAndKey();
      int numberOfBuilds = 0;
      int sum(Ref ref, List<int> args) {
        numberOfBuilds++;
        return args.reduce((value, element) => value + element);
      }

      expect(store.getw(sum.w([2, 20, 6, 14]), globalKey: key), 42);
      expect(store.getw(sum.w([2, 20, 6, 14]), globalKey: key), 42);
      expect(numberOfBuilds, 1);
    });

    test('getw with same tag multiple times', () {
      final (store, key) = initStoreAndKey();
      int numberOfBuilds = 0;
      int add(Ref ref, (int, int) args) {
        numberOfBuilds++;
        return args.$1 + args.$2;
      }

      final params = (20, 22);
      expect(store.getw(add.w(params), tag: params), 42);
      expect(store.getw(add.w(params), tag: params), 42);
      print(store.cache);
      expect(numberOfBuilds, 1);
    });

    test('getw with different tags', () {
      final (store, key) = initStoreAndKey();
      int add(Ref ref, (int, int) args) {
        return args.$1 + args.$2;
      }

      final params1 = (20, 22);
      final params2 = (1, 3);
      expect(store.getw(add.w(params1), tag: params1), 42);
      expect(store.getw(add.w(params2), tag: params2), 4);
    });
  });
}
