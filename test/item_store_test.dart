import 'dart:math';

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
  (ItemStore, String, int Function(Ref)) initialVariables() =>
      (ItemStore(), 'key', (_) => 42);

  group('ItemStore', () {
    test('create', () {
      final (store, key, itemFactory) = initialVariables();
      final item = store.write(itemFactory.p(), globalKey: key);
      expect(item, 42);
    });

    test('read', () {
      final (store, key, itemFactory) = initialVariables();
      store.write(itemFactory.p());
      expect(store.read(itemFactory), 42);
    });

    test('readByKey', () {
      final (store, key, itemFactory) = initialVariables();
      store.write(itemFactory.p(), globalKey: key);
      expect(store.readByKey(key), 42);
    });

    test('get with globalKey multiple times', () {
      final (store, key, itemFactory) = initialVariables();
      int otherFactory(Ref _) => 0;

      expect(store.get<int>(itemFactory.p(), globalKey: key), 42);
      expect(store.get<int>(otherFactory.p(), globalKey: key), 42);
    });

    test('get with the same non null dependencies', () {
      final (store, key, _) = initialVariables();
      int itemData = 0;
      int incNumberFactory(Ref _) => itemData++;

      expect(
        store.get(incNumberFactory.p(), dependencies: [0]),
        store.get(incNumberFactory.p(), dependencies: [0]),
      );
    });

    test('get with the both dependencies as null', () {
      final (store, key, _) = initialVariables();
      int itemData = 0;
      int incNumberFactory(Ref _) => itemData++;

      expect(
        store.get(incNumberFactory.p()),
        store.get(incNumberFactory.p()),
      );
    });

    test('get with dependencies with same length, but different values', () {
      final (store, key, _) = initialVariables();
      int itemData = 0;
      int incNumberFactory(Ref _) => itemData++;

      final firstItem = store.get(incNumberFactory.p(), dependencies: [0]);
      final secondItem = store.get(incNumberFactory.p(), dependencies: [1]);

      expect(firstItem, 0);
      expect(secondItem, 1);
      expect(firstItem, isNot(secondItem));
      expect(itemData, 2);
    });

    test('get with dependencies with different length', () {
      final (store, key, _) = initialVariables();
      int itemData = 0;
      int incNumberFactory(Ref _) => itemData++;

      final firstItem = store.get(incNumberFactory.p(), dependencies: [0]);
      final secondItem = store.get(incNumberFactory.p(), dependencies: [0, 1]);

      expect(firstItem, 0);
      expect(secondItem, 1);
      expect(firstItem, isNot(secondItem));
      expect(itemData, 2);
    });

    test('get with first dependencies being null', () {
      final (store, key, _) = initialVariables();
      int itemData = 0;
      int incNumberFactory(Ref _) => itemData++;

      final firstItem = store.get(incNumberFactory.p());
      final secondItem = store.get(incNumberFactory.p(), dependencies: [0, 1]);

      expect(firstItem, 0);
      expect(secondItem, 1);
      expect(firstItem, isNot(secondItem));
      expect(itemData, 2);
    });

    test('get with second dependencies being null', () {
      final (store, key, _) = initialVariables();
      int itemData = 0;
      int incNumberFactory(Ref _) => itemData++;

      final firstItem = store.get(incNumberFactory.p(), dependencies: [0]);
      final secondItem = store.get(incNumberFactory.p());

      expect(firstItem, 0);
      expect(secondItem, 1);
      expect(firstItem, isNot(secondItem));
      expect(itemData, 2);
    });
  });

  group('Ref', () {
    test('onDispose', () {
      final (store, key, _) = initialVariables();
      bool disposed = false;
      itemFactory(Ref ref) {
        ref.onDispose(() => disposed = true);
        return 42;
      }

      // int counter(Ref ref, [int initial = 0]) {
      //   return (
      //     ref.reader(counter)(),
      //     () => ref.writer(counter)(initial + 1),
      //   );
      // }

      // final counter = store.getter(counter)();
      // final counter = store.getter(tag: 'main', counter)();

      // final (getCount, incCount) = store.writer(counter)();
      // store.writer((_, x) => x, globalKey: 'count')(5);

      store.write(itemFactory.p(), globalKey: key);
      store.disposeItem(key);

      expect(disposed, true);
    });
  });

  group('Type as key', () {
    (ItemStore, Type) initStoreAndTypeKey() => (ItemStore(), CustomKey);

    test('create', () {
      final (store, key) = initStoreAndTypeKey();
      final Type otherKey = OtherCustomKey;

      final item = store.write(((_) => 42).p(), globalKey: key);
      final otherItem = store.write(((_) => 'other').p(), globalKey: otherKey);

      expect(item, 42);
      expect(otherItem, 'other');
    });

    test('read', () {
      final (store, key) = initStoreAndTypeKey();
      final Type otherKey = OtherCustomKey;

      store.write(((_) => 42).p(), globalKey: key);
      store.write(((_) => 'other').p(), globalKey: otherKey);

      expect(store.readByKey(key), 42);
      expect(store.readByKey(otherKey), 'other');
    });

    test('get', () {
      final (store, key) = initStoreAndTypeKey();
      final Type otherKey = OtherCustomKey;

      expect(store.get(((_) => 42).p(), globalKey: key), 42);
      expect(store.get(((_) => 'other').p(), globalKey: otherKey), 'other');
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

  group('ItemStore "p" syntax', () {
    test('write with parameters', () {
      final (store, key, _) = initialVariables();
      int sum(Ref ref, List<int> args) =>
          args.reduce((value, element) => value + element);

      final item = store.write(sum.p([2, 20, 6, 14]), globalKey: key);

      expect(item, 42);
    });

    test('read', () {
      final (store, key, _) = initialVariables();
      int sum(Ref ref, List<int> args) =>
          args.reduce((value, element) => value + element);

      store.write(sum.p([2, 20, 6, 14]), globalKey: key);

      expect(store.readByKey(key), 42);
    });

    test('getw by globalKey', () {
      final (store, key, _) = initialVariables();
      int numberOfBuilds = 0;
      int sum(Ref ref, List<int> args) {
        numberOfBuilds++;
        return args.reduce((value, element) => value + element);
      }

      expect(store.get(sum.p([2, 20, 6, 14]), globalKey: key), 42);
      expect(store.get(sum.p([2, 20, 6, 14]), globalKey: key), 42);
      expect(numberOfBuilds, 1);
    });

    test('getw with same tag multiple times', () {
      final (store, key, _) = initialVariables();
      int numberOfBuilds = 0;
      int add(Ref ref, (int, int) args) {
        numberOfBuilds++;
        return args.$1 + args.$2;
      }

      final params = (20, 22);
      expect(store.get(add.p(params), tag: params), 42);
      expect(store.get(add.p(params), tag: params), 42);
      expect(numberOfBuilds, 1);
    });

    test('getw with different tags', () {
      final (store, key, _) = initialVariables();
      int add(Ref ref, (int, int) args) {
        return args.$1 + args.$2;
      }

      final params1 = (20, 22);
      final params2 = (1, 3);
      expect(store.get(add.p(params1), tag: params1), 42);
      expect(store.get(add.p(params2), tag: params2), 4);
    });
  });
}
