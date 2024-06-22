import 'package:item_store_flutter/src/notifiers_extended/listenable_listener.dart';
import 'package:item_store_flutter/src/notifiers_extended/state_notifier.dart';

/// Runs a batch operation on [StateNotifier] objects.
///
/// The [callback] function is called with a single argument, [silentSet], which
/// is a function that sets the value of a [StateNotifier] object without
/// notifying its listeners.
///
/// After the [callback] has executed, all listeners of the [StateNotifier]
/// objects that were modified are called exactly once.
void batch(
    void Function(void Function<T>(StateNotifier<T>, T) silentSet) callback) {
  // List of StateNotifier objects that were modified during the batch operation.
  final modifiedNotifiers = <StateNotifier>[];

  // Function that sets the value of a StateNotifier object without notifying its
  // listeners, and saves it into the list of modified notifiers.
  void silentSet<T>(StateNotifier<T> notifier, T newValue) {
    notifier.silentSet(newValue);
    modifiedNotifiers.add(notifier);
  }

  // Call the callback function with the silentSet function as the argument.
  callback(silentSet);

  // Create a set to store the distinct listeners.
  final distinctListeners = <void Function()>{};

  // Add all listeners to the set.
  for (final notifier in modifiedNotifiers) {
    // Use the exposed ListenableListenerMixin to access the dependencies of the
    // notifier.
    (notifier as ExposedListenableListenerMixin)
        .dependencies
        .values
        .forEach(distinctListeners.add);
  }

  // Call each listener exactly once.
  for (var listener in distinctListeners) {
    listener();
  }
}
