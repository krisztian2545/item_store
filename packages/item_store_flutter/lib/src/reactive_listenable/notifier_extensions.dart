import 'package:item_store_flutter/src/reactive_listenable/readonly_state_notifier.dart';
import 'state_notifier.dart';

extension StateNotifierX<T> on StateNotifier<T> {
  ReadonlyStateNotifier<T> get readonly => this as ReadonlyStateNotifier<T>;
}
