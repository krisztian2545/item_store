import 'package:item_store/item_store.dart';
import 'package:item_store_flutter/src/reactive_listenable/disposable_mixin.dart';
import 'package:item_store_flutter/src/reactive_listenable/readonly_state_notifier.dart';
import 'state_notifier.dart';

extension NotifierRefX on Ref {
  R bindToDisposable<T, R extends DisposableMixin>(R disposable) {
    return registerDisposable(disposable..onDispose(disposeSelf));
  }
}

extension StateNotifierX<T> on StateNotifier<T> {
  ReadonlyStateNotifier<T> get readonly => this as ReadonlyStateNotifier<T>;
}
