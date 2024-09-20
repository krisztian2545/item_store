import 'package:signal_store/signal_store.dart';
import 'package:test/test.dart';

// void main() {
//   (ItemStore, String) initStoreAndKey() => (ItemStore(), 'key');

//   group('Signal autoDispose', () {
//     test('auto disposes signals', () {
//       final (store, key) = initStoreAndKey();
//       int timesCreated = 0;
//       final item = store.getw(
//         (Ref ref, int initialValue) {
//           timesCreated++;

//           final valueSignal = signal(initialValue, autoDispose: true);

//           return ref.bindTo(valueSignal);
//         }.w(42),
//         globalKey: key,
//       );

//       final listener = store.get((ref) {

//       });

//       expect(item, 42);
//     });

//     test('read', () {
//       final (store, key) = initStoreAndKey();
//       store.create((_) => 42, globalKey: key);
//       expect(store.read(key), 42);
//     });

//     test('get with globalKey multiple times', () {
//       final (store, key) = initStoreAndKey();
//       expect(store.get<int>((_) => 42, globalKey: key), 42);
//       expect(store.get<int>((_) => 0, globalKey: key), 42);
//     });
//   });
// }
