import 'package:item_store_flutter/src/reactive_listenable/custom_change_notifier.dart';
import 'package:item_store_flutter/src/reactive_listenable/state_notifier.dart';

/// Runs a batch operation on [StateNotifier] objects.
///
/// The [operation] function provides a [silentSet] function to set the
/// value of a [StateNotifier] object without notifying its listeners.
///
/// After the [operation] has executed, all listeners of the [StateNotifier]
/// objects that were modified by the provided [silentSet] function,
/// are called exactly once.
void batch(
    void Function(void Function<T>(StateNotifier<T>, T) silentSet) operation) {
  final modifiedNotifiers = <StateNotifier>[];

  // A callback to set the value of a StateNotifier object without notifying its
  // listeners, and to save it into the list of modified notifiers.
  void silentSet<T>(StateNotifier<T> notifier, T newValue) {
    notifier.silentSet(newValue);
    modifiedNotifiers.add(notifier);
  }

  operation(silentSet);

  // We only need the distinct listeners, to avoid notifying the same listener
  // more than once.
  final distinctListeners = <void Function()>{};
  for (final notifier in modifiedNotifiers) {
    // We use the ExposedChangeNotifier to access the listeners of the notifier.
    (notifier as ExposedChangeNotifier)
        .listeners
        .forEach(distinctListeners.add);
  }

  for (var listener in distinctListeners) {
    listener();
  }
}
