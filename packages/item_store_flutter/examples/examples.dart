import 'package:flutter/material.dart';
import 'package:item_store_flutter/item_store_flutter.dart';

// class Counter extends StateNotifier {
//   Counter(ValueNotifier jumpTo) : super(0) {
//     listenTo(jumpTo, () => value = jumpTo.value);
//   }
// }

// class CountDoubled extends StateNotifier<int> {
//   CountDoubled(ValueNotifier count)
//       : super(
//           count.value * 2,
//           autoDispose: true,
//         ) {
//     listenTo(count, () => value = count.value * 2);
//   }
// }

// final counter = (Ref ref) {
//   final count = ref.bindToDisposable(StateNotifier(0));
//   return (
//     count.readonly,
//     increment: () => count.value++,
//   );
// };

(T Function(), void Function(T)) createState<T>(T initialValue) {
  T state = initialValue;
  return (() => state, (newState) => state = newState);
}

(T Function(), void Function(T)) Function(Ref) createStateFactory<T>(
    T initialValue) {
  return (_) => createState(initialValue);
}

T? Function(T) previousValueHolder<T>(Ref ref) {
  T? previousValue;

  return (T newValue) {
    final temp = previousValue;
    previousValue = newValue;
    return temp;
  };
}

// AsyncReactive<int> countDouble(Ref ref) {
//   int? previous;
//   final (getSome, setSome) = createState(0);
//   return ref.bindToDisposable(AsyncReactive((watch) async {
//     final count = watch(ref(counter).$1);
//     final countDoubled = count.value * 2;

//     final prev = ref.local(previousValueHolder)(countDoubled);
//     print('$previous ($prev) > $countDoubled');

//     previous = countDoubled;
//     return countDoubled;
//   }));
// }

ValueNotifier<int> counterNotifier(Ref ref) => ValueNotifier(0);

class CounterWidget extends ItemConsumer {
  const CounterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
