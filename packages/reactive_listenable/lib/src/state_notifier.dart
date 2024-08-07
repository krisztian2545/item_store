import 'package:flutter/foundation.dart';
import 'custom_change_notifier.dart';
import 'disposable_mixin.dart';
import 'listenable_listener.dart';

import 'change_observer.dart';

typedef WatchFunction = T Function<T extends Listenable>(T listenable);

class ChangeNotifier2 extends ChangeNotifierCopy {
  void notifierDispose() => super.dispose();
}

class StateNotifier<T> extends ChangeNotifier2
    with ListenableListenerMixin, ObservedDisposableMixin
    implements ValueListenable<T> {
  StateNotifier(this._value, {this.autoDispose = false, this.debugLabel}) {
    if (kFlutterMemoryAllocationsEnabled) {
      ChangeNotifierCopy.maybeDispatchObjectCreation(this);
    }
  }

  StateNotifier.lateInit({this.autoDispose = false, this.debugLabel}) {
    if (kFlutterMemoryAllocationsEnabled) {
      ChangeNotifierCopy.maybeDispatchObjectCreation(this);
    }
  }

  final String? debugLabel;

  @override
  T get value => _value;
  late T _value;
  set value(T newValue) => set(newValue, forceUpdate: false);

  void set(T newValue, {bool forceUpdate = false}) {
    if (!forceUpdate) {
      if (_value == newValue) {
        return;
      }
    }
    _value = newValue;
    ReactiveListenableObserver.observer?.onChange(this);
    notifyListeners();
  }

  /// Set value without notifying listeners.
  void silentSet(T newValue) {
    _value = newValue;
    ReactiveListenableObserver.observer?.onChange(this);
  }

  @override
  String toString() => '${describeIdentity(this)}($value)';

  /// Automatically disposes when the last listener unsubscribes from this notifier.
  final bool autoDispose;

  @override
  L listenTo<L extends Listenable>(L dependency, VoidCallback callback) {
    return super.listenTo(dependency, () {
      try {
        callback();
      } catch (e, stack) {
        ReactiveListenableObserver.observer?.onError(this, e, stack);
        rethrow;
      }
    });
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (hasListeners || !autoDispose) return;
    dispose();
  }

  @override
  void dispose() {
    // calls dispose callbacks
    super.dispose();
    clearDependencies();
    notifierDispose();
  }
}
