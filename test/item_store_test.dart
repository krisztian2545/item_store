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
    test('write', () {
      final (store, _, itemFactory) = initialVariables();
      final item = store.write(itemFactory);
      expect(item, 42);
    });

    test('write with global key', () {
      final (store, key, itemFactory) = initialVariables();
      final item = store.write(itemFactory, globalKey: key);
      expect(item, 42);
    });

    test('read', () {
      final (store, _, itemFactory) = initialVariables();
      store.write(itemFactory);
      expect(store.read(itemFactory), 42);
    });

    test('readByKey', () {
      final (store, key, itemFactory) = initialVariables();
      store.write(itemFactory, globalKey: key);
      expect(store.readByKey(key), 42);
    });

    test('get with globalKey multiple times', () {
      final (store, key, itemFactory) = initialVariables();
      int otherFactory(Ref _) => 0;

      expect(store.get<int>(itemFactory, globalKey: key), 42);
      expect(store.get<int>(otherFactory, globalKey: key), 42);
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

        store.write(itemFactory, globalKey: key);
        store.disposeItem(key);

        expect(disposed, true);
      });
    });

    group('Type as key', () {
      (ItemStore, Type) initStoreAndTypeKey() => (ItemStore(), CustomKey);

      test('write', () {
        final (store, key) = initStoreAndTypeKey();
        final Type otherKey = OtherCustomKey;

        final item = store.write(((_) => 42), globalKey: key);
        final otherItem = store.write(((_) => 'other'), globalKey: otherKey);

        expect(item, 42);
        expect(otherItem, 'other');
      });

      test('read', () {
        final (store, key) = initStoreAndTypeKey();
        final Type otherKey = OtherCustomKey;

        store.write(((_) => 42), globalKey: key);
        store.write(((_) => 'other'), globalKey: otherKey);

        expect(store.readByKey(key), 42);
        expect(store.readByKey(otherKey), 'other');
      });

      test('get', () {
        final (store, key) = initStoreAndTypeKey();
        final Type otherKey = OtherCustomKey;

        expect(store.get(((_) => 42), globalKey: key), 42);
        expect(store.get(((_) => 'other'), globalKey: otherKey), 'other');
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
        final retrievedTaggedPerson =
            store.writeValue(taggedPerson, tag: "tag");
        final retrievedTaggedAnimal =
            store.writeValue(taggedAnimal, tag: "tag");

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

    // group('ItemStore "p" syntax', () {
    //   test('write with parameters', () {
    //     final (store, _, _) = initialVariables();
    //     int sum(Ref ref, List<int> args) =>
    //         args.reduce((value, element) => value + element);

    //     final item = store.write(sum.p([2, 20, 6, 14]));

    //     expect(item, 42);
    //   });

    //   test('read', () {
    //     final (store, _, _) = initialVariables();
    //     int sum(Ref ref, List<int> args) =>
    //         args.reduce((value, element) => value + element);
    //     final args = [2, 20, 6, 14];

    //     store.write(sum.p(args));

    //     expect(store.read(sum.p(args)), 42);
    //   });

    //   test('get by globalKey', () {
    //     final (store, key, _) = initialVariables();
    //     int numberOfBuilds = 0;
    //     int sum(Ref ref, List<int> args) {
    //       numberOfBuilds++;
    //       return args.reduce((value, element) => value + element);
    //     }

    //     final args = [2, 20, 6, 14];

    //     expect(store.get(sum.p(args), globalKey: key), 42);
    //     expect(store.get(sum.p(args), globalKey: key), 42);
    //     expect(numberOfBuilds, 1);
    //   });

    //   test('get with same tag multiple times', () {
    //     final (store, key, _) = initialVariables();
    //     int numberOfBuilds = 0;
    //     int add(Ref ref, (int, int) args) {
    //       numberOfBuilds++;
    //       return args.$1 + args.$2;
    //     }

    //     final params = (20, 22);
    //     expect(store.get(add.p(params)), 42);
    //     expect(store.get(add.p(params)), 42);
    //     expect(numberOfBuilds, 1);
    //   });

    //   test('get with different tags', () {
    //     final (store, key, _) = initialVariables();
    //     int add(Ref ref, (int, int) args) {
    //       return args.$1 + args.$2;
    //     }

    //     final params1 = (20, 22);
    //     final params2 = (1, 3);
    //     expect(store.get(add.p(params1)), 42);
    //     expect(store.get(add.p(params2)), 4);
    //   });
    // });
  });
}
