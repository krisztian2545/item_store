import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:item_store_flutter/src/notifiers_extended/disposable_mixin.dart';
import 'package:item_store_flutter/src/notifiers_extended/listenable_listener.dart';

import 'async_state.dart';
import 'change_observer.dart';
import 'state_notifier.dart';

class Reactive<T> extends StateNotifier<T> {
  Reactive(
    this._compute, {
    bool lazy = true,
    super.autoDispose,
    super.debugLabel,
  }) : super.lateInit() {
    if (!lazy) {
      _computeAndCache();
    }
  }

  bool _needsBuild = true;

  L _watch<L extends Listenable>(L dependency) {
    return listenTo(dependency, _handleDependencyChanged);
  }

  void _handleDependencyChanged() {
    _computeAndCache();
  }

  @override
  T get value => _needsBuild ? _computeAndCache() : super.value;

  final T Function(WatchFunction) _compute;

  T _computeAndCache() {
    clearDependencies();

    final T newValue;
    try {
      newValue = _compute(_watch);
      value = newValue;
    } catch (e) {
      ChangeObserver.observer?.onError(this, e, StackTrace.current);
      rethrow;
    }

    _needsBuild = false;
    return newValue;
  }

  void invalidate() => _needsBuild = true;

  void recompute() => _computeAndCache();
}

class AsyncReactive<T> extends StateNotifier<AsyncState<T>> {
  AsyncReactive(
    this._compute, {
    bool lazy = true,
    super.autoDispose,
    super.debugLabel,
  }) : super.lateInit() {
    if (!lazy) {
      _computeAndCache();
    }
  }

  bool _needsBuild = true;

  L _watch<L extends Listenable>(L dependency) {
    return listenTo(dependency, _handleDependencyChanged);
  }

  void _handleDependencyChanged() {
    _computeAndCache();
  }

  @override
  AsyncState<T> get value => _needsBuild ? _computeAndCache() : super.value;

  final Future<T> Function(WatchFunction) _compute;

  AsyncState<T> _computeAndCache() {
    value = AsyncLoading();
    clearDependencies();

    _compute(_watch).then((data) => value = AsyncData(data)).catchError((err) {
      value = AsyncError(err, StackTrace.current);
    });

    _needsBuild = false;
    return super.value;
  }

  void invalidate() => _needsBuild = true;

  void recompute() => _computeAndCache();
}

class Effect with ListenableListenerMixin, DisposableMixin {
  Effect(
    this.effect, {
    required List<Listenable> dependencies,
    this.debugLabel,
  }) {
    for (final dependency in dependencies) {
      listenTo(dependency, effect);
    }
  }

  final String? debugLabel;

  final FutureOr<void> Function() effect;

  @override
  void dispose() {
    super.dispose();
    clearDependencies();
  }
}
