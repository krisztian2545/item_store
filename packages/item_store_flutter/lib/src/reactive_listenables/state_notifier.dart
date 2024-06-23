import 'package:flutter/foundation.dart';
import 'package:item_store_flutter/src/reactive_listenables/custom_change_notifier.dart';
import 'package:item_store_flutter/src/reactive_listenables/disposable_mixin.dart';
import 'package:item_store_flutter/src/reactive_listenables/listenable_listener.dart';

import 'change_observer.dart';

typedef WatchFunction = T Function<T extends Listenable>(T listenable);

class ChangeNotifier2 extends ChangeNotifierCopy {
  void notifierDispose() => super.dispose();
}

class StateNotifier<T> extends ChangeNotifier2
    with ListenableListenerMixin, DisposableMixin
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
    ChangeObserver.observer?.onChange(this);
    notifyListeners();
  }

  /// Set value without notifying listeners.
  void silentSet(T newValue) {
    _value = newValue;
    ChangeObserver.observer?.onChange(this);
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
      } catch (e) {
        ChangeObserver.observer?.onError(this, e, StackTrace.current);
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
