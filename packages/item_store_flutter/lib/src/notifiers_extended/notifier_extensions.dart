import 'package:item_store/item_store.dart';
import 'package:item_store_flutter/src/notifiers_extended/disposable_mixin.dart';
import 'package:item_store_flutter/src/notifiers_extended/readonly_state_notifier.dart';
import 'async_state.dart';
import 'state_notifier.dart';

extension NotifierRefX on Ref {
  R bindToDisposable<T, R extends DisposableMixin>(R disposable) {
    return registerDisposable(disposable..onDispose(disposeSelf));
  }
}

extension StateNotifierX<T> on StateNotifier<T> {
  ReadonlyStateNotifier<T> get readonly => this as ReadonlyStateNotifier<T>;
  StateNotifier toStateNotifier() {
    final stateNotifier = StateNotifier(value);
    final listener = () => stateNotifier.value = value;

    addListener(listener);
    stateNotifier.onDispose(() => removeListener(listener));

    return stateNotifier;
  }
}

extension AsyncStateX<T> on AsyncState<T> {
  R when<R>({
    required R Function() loading,
    required R Function(T data) data,
    required R Function(Object? error, StackTrace? stackTrace) error,
  }) {
    return switch (this) {
      AsyncLoading() => loading(),
      AsyncData(data: final state) => data(state),
      AsyncError(error: final e, stackTrace: final stack) => error(e, stack),
    };
  }
}
