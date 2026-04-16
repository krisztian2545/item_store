A dependency injection library inspired by Riverpod and Rearch. Designed to increase development productivity by balancing automation and control.

- small but powerful core API surface
- automatic and manual memory management
- optional dependency tracking
- allows high composition
- scoped containers
- can be used in both dart and Flutter projects
- no code generation
- utility methods to use it with Signals

## Usage

Setup:
```dart
// In dart
final store = ItemStore();

// In Flutter
ItemStoreProvider(child: App()),
// or
ItemStoreProvider.value(
  store: itemStore,
  child: App(),
),
```

Define a factory method
```dart
final counterNotifier = (Ref ref) {
    final counter = ValueNotifier(0);
    ref.onDispose(counter.dispose);
    // or just:
    // final counter = ValueNotifier(0).bindTo(ref); // this ensures that the object and the item always gets disposed together
    return counter;
};
```

Run the factory and store it's result
```dart
store.write(counterNotifier);
// or store the result under a different key than the factory
store.write(counterNotifier, key: (counterNotifier, userId));
store.write(mockCounterNotifier, key: counterNotifier);
```

Read the value created by a factory, or null if it hasn't been created yet
```dart
final maybeCounter = store.read(counterNotifier);
```

Reads the item from the store and creates it if it hasn't been yet
```dart
final counter = store.get(counterNotifier);
// or inside a factory
void getExampleFactory(Ref ref) {
    final counter = ref(counterNotifier);
    // ...
}
```

Manually remove an item from the store
```dart
store.disposeItem(counterNotifier);
```

Use any factory inside your factory without making them public
```dart
final counterController = (Ref ref) {
    final counter = ref.local(counterNotifier).bindto(ref);
    return (counter, () => counter.value++);
};
```

Define a dependency on an item to dispose it when it's source get's disposed, and get the fresh value next time you get it
```dart
final nameFactory = (ref) => 'John Doe';
final firstName = (ref) {
    final name = ref.dep(nameFactory);
    return name.split(' ')[0];
};
```

// In Flutter widgets
```dart
class CounterWidget extends ItemConsumer {
  const CounterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalCounter = ref(counterNotifier);
    // or in any widget: final globalCounter = context.store(counterNotifier); // context.readStore inside stateless widgets
    final localCounter = ref.local(counterNotifier);
    return ValueListenableBuilder(
      valueListenable: localCounter,
      builder: (context, count, _) => TextButton(
        onPressed: () => localCounter.value++,
        child: Text('$count'),
      ),
    );
  }
}
// or in stateful widgets
class MyWidget extends StatefulWidget {
    /// ...
}
class _MyWidgetState extends State<MyWidget> with WidgetRefMixin {
    /// access ref anywhere
}
```
