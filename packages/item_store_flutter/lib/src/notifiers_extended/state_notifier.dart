import 'package:flutter/foundation.dart';
import 'package:item_store_flutter/src/notifiers_extended/listenable_listener.dart';

import 'state_notifier_observer.dart';

typedef WatchFunction = T Function<T extends Listenable>(T listenable);

class StateNotifier<T> extends ChangeNotifier
    with ListenableListenerMixin
    implements ValueListenable<T> {
  StateNotifier(this._value, {this.autoDispose = false, this.debugLabel}) {
    if (kFlutterMemoryAllocationsEnabled) {
      ChangeNotifier.maybeDispatchObjectCreation(this);
    }
  }

  StateNotifier.lateInit({this.autoDispose = false, this.debugLabel}) {
    if (kFlutterMemoryAllocationsEnabled) {
      ChangeNotifier.maybeDispatchObjectCreation(this);
    }
  }

  static StateNotifierObserver? observer;

  final String? debugLabel;

  @override
  T get value => _value;
  late T _value;
  set value(T newValue) {
    if (_value == newValue) {
      return;
    }
    _value = newValue;
    observer?.onChange(this);
    notifyListeners();
  }

  @override
  String toString() => '${describeIdentity(this)}($value)';

  final bool autoDispose;

  final _disposeCallbacks = <VoidCallback>[];

  @override
  L listenTo<L extends Listenable>(L dependency, VoidCallback callback) {
    return super.listenTo(dependency, () {
      try {
        callback();
      } catch (e) {
        observer?.onError(this, e, StackTrace.current);
      }
    });
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (hasListeners || !autoDispose) return;
    dispose();
  }

  void onDispose(void Function() callback) => _disposeCallbacks.add(callback);

  @override
  void dispose() {
    for (final callback in _disposeCallbacks) {
      try {
        callback();
      } catch (e) {
        observer?.onError(this, e, StackTrace.current);
      }
    }
    clearDependencies();
    super.dispose();
  }
}
