import 'package:flutter/material.dart';
import 'package:item_store/item_store.dart';
import 'package:item_store_flutter/src/item_consumer.dart';
import 'package:item_store_flutter/src/reactive_listenable/reactive_listenable.dart';

class Counter extends StateNotifier {
  Counter(ValueNotifier jumpTo) : super(0) {
    listenTo(jumpTo, () => value = jumpTo.value);
  }
}

T Function(Ref) dof<T>(T Function(Ref) objectFactory) {
  return (ref) {
    final o = objectFactory(ref);
    try {
      // dispose object when being removed from the store
      final callback = (o as dynamic).dispose as void Function();
      ref.onDispose(callback);

      // dispose item from the store, when object gets disposed
      (o as dynamic).onDispose(ref.disposeSelf);
    } catch (e) {
      // disposable doesn't have a void dispose() function
      // or doesn't accept an onDispose callback.
    }

    return o;
  };
}

class CountDoubled extends StateNotifier<int> {
  CountDoubled(ValueNotifier count)
      : super(
          count.value * 2,
          autoDispose: true,
        ) {
    listenTo(count, () => value = count.value * 2);
  }
}

final counter = (Ref ref) {
  final count = ref.bindToDisposable(StateNotifier(0));
  return (
    count.readonly,
    increment: () => count.value++,
  );
};

(T Function(), void Function(T)) createState<T>(T initialValue) {
  T state = initialValue;
  return (() => state, (newState) => state = newState);
}

(T Function(), void Function(T)) Function(Ref) createStateFactory<T>(
    T initialValue) {
  return (_) => createState(initialValue);
}

T? Function(Ref) previousValueFactory<T>(T current) {
  return (ref) {
    final (getPrevious, setPrevious) =
        ref.local.get(createStateFactory<T?>(null));
    final previous = getPrevious();
    setPrevious(current);

    return previous;
  };
}

AsyncReactive<int> countDouble(Ref ref) {
  int? previous;
  final (getSome, setSome) = createState(0);
  return ref.bindToDisposable(AsyncReactive((watch) async {
    final count = watch(ref(counter).$1);
    final countDoubled = count.value * 2;

    final prev = ref.local(previousValueFactory(countDoubled));
    print('$previous ($prev) > $countDoubled');

    previous = countDoubled;
    return countDoubled;
  }));
}

ValueNotifier<int> counterNotifier(Ref ref) => ValueNotifier(0);

class CounterWidget extends ItemConsumer {
  const CounterWidget({super.key});

  @override
  Widget build(BuildContext context, Ref ref) {
    final countNotifier = ref.local(counterNotifier);
    return ValueListenableBuilder(
      valueListenable: countNotifier,
      builder: (context, count, _) => TextButton(
        onPressed: () => countNotifier.value++,
        child: Text('$count'),
      ),
    );
  }
}
