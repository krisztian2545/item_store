import 'package:flutter/foundation.dart';
import 'reactive.dart';

import 'state_notifier.dart';

/// Base class for observing changes in [StateNotifier]s, [Reactive]s,
/// [AsyncReactive]s and [Effect]s.
///
/// Set the current observer by setting the value of
/// [ReactiveListenableObserver.observer].
///
/// The default implementation of the observer is
/// [DefaultReactiveListenableObserver].
abstract class ReactiveListenableObserver {
  /// The currently set observer.
  ///
  /// By default, this is an instance of [DefaultReactiveListenableObserver].
  static ReactiveListenableObserver? observer = createDefaultObserver();

  /// Creates a new default observer.
  ///
  /// The default implementation of the observer is [DefaultReactiveListenableObserver].
  static ReactiveListenableObserver createDefaultObserver() =>
      DefaultReactiveListenableObserver();

  /// Called when a [ReactiveListenable] changes.
  ///
  /// The [observedObject] is the object that has changed.
  void onChange(Object observedObject);

  /// Called when an error occurs while observing a [ReactiveListenable].
  ///
  /// The [observedObject] is the object that the error occurred in.
  /// The [error] is the error that occurred.
  /// The [stackTrace] is the stack trace at the point when the error occurred.
  void onError(Object observedObject, Object error, StackTrace stackTrace);
}

class DefaultReactiveListenableObserver extends ReactiveListenableObserver {
  @override
  void onChange(Object observedObject) {
    if (kDebugMode) {
      switch (observedObject) {
        case StateNotifier():
          debugPrint(
              "[StateNotifier changed] ($observedObject)${observedObject.debugLabel}: ${observedObject.value}");
        case Effect():
          debugPrint(
              "[Effect run] ($observedObject)${observedObject.debugLabel}");
        default:
          debugPrint("[Object changed] $observedObject");
      }
    }
  }

  @override
  void onError(Object observedObject, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint("[Error] $observedObject: $error\nStackTrace: $stackTrace");
    }
  }
}
