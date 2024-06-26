import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:item_store_flutter/src/reactive_listenable/disposable_mixin.dart';
import 'package:item_store_flutter/src/reactive_listenable/listenable_listener.dart';

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
    return listenTo(dependency, _computeAndCache);
  }

  @override
  T get value => _needsBuild ? _computeAndCache() : super.value;

  final T Function(WatchFunction) _compute;

  T _computeAndCache() {
    clearDependencies();

    final T newValue;
    try {
      newValue = _compute(_watch);
      set(newValue, forceUpdate: _needsBuild);
    } catch (e, stack) {
      ReactiveListenableObserver.observer?.onError(this, e, stack);
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
    set(AsyncLoading(), forceUpdate: _needsBuild);
    clearDependencies();

    _compute(_watch).then((data) => value = AsyncData(data)).catchError((err) {
      final stack = StackTrace.current;
      value = AsyncError(err, stack);
      ReactiveListenableObserver.observer?.onError(this, err, stack);
    });

    _needsBuild = false;
    return super.value;
  }

  void invalidate() => _needsBuild = true;

  void recompute() => _computeAndCache();
}

class Effect with ListenableListenerMixin, DisposableMixin {
  Effect(
    FutureOr<void> Function(L Function<L extends Listenable>(L)) effect, {
    this.debugLabel,
  }) {
    effect(_watch);
    this.effect = () async {
      clearDependencies();
      await effect(_watch);
    };
  }

  Effect.late(
    this.effect, {
    required List<Listenable> dependencies,
    this.debugLabel,
  }) {
    for (final dependency in dependencies) {
      _watch(dependency);
    }
  }

  final String? debugLabel;

  late final FutureOr<void> Function() effect;

  Future<void> _observedEffect() async {
    try {
      await effect();
      ReactiveListenableObserver.observer?.onChange(this);
    } catch (e, stack) {
      ReactiveListenableObserver.observer?.onError(this, e, stack);
    }
  }

  L _watch<L extends Listenable>(L dependency) {
    return listenTo(dependency, _observedEffect);
  }

  @override
  void dispose() {
    super.dispose();
    clearDependencies();
  }
}
