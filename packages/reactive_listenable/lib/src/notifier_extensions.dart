import 'readonly_state_notifier.dart';
import 'state_notifier.dart';

extension StateNotifierX<T> on StateNotifier<T> {
  ReadonlyStateNotifier<T> get readonly => this as ReadonlyStateNotifier<T>;
}
