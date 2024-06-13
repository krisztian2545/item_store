import 'package:flutter/foundation.dart';
import 'package:item_store_flutter/src/notifiers_extended/state_notifier.dart';

// typedef WatchFunction = T Function<T extends Listenable>(T listenable);

// class Reactive<T> extends StateNotifier<T?> {
//   Reactive(
//     this._compute, {
//     bool lazy = true,
//     super.autoDispose,
//   }) {
//     if (!lazy) {
//       _computeAndCache();
//     }
//   }

//   L _watch<L extends Listenable>(L dependency) {
//     if (!_dependencies.contains(dependency)) {
//       _dependencies.add(dependency);
//     }
//     return dependency;
//   }

//   void _handleDependencyChanged() {
//     _computeAndCache();
//   }

//   // T? _cache;

//   @override
//   T get value => super.value ?? _computeAndCache();

//   final T Function(WatchFunction) _compute;

//   T _computeAndCache() {
//     _clearDependencies();

//     value = _compute(_watch);
//     _listenDependencies();

//     return value!;
//   }

//   void invalidate() => value = null;

//   void recompute() => _computeAndCache();

// }

// class Reactive<T> extends ChangeNotifier implements ValueListenable<T> {
//   Reactive(
//     this._compute, {
//     bool lazy = true,
//     this.autoDispose = false,
//   }) {
//     if (!lazy) {
//       _computeAndCache();
//     }
//   }

//   final bool autoDispose;

//   L _watch<L extends Listenable>(L dependency) {
//     if (!_dependencies.contains(dependency)) {
//       _dependencies.add(dependency);
//     }
//     return dependency;
//   }

//   final List<Listenable> _dependencies = <Listenable>[];
//   Listenable? _combinedDependencies;

//   void _listenDependencies() {
//     _combinedDependencies = Listenable.merge(_dependencies);
//     _combinedDependencies?.addListener(_handleDependencyChanged);
//   }

//   void _clearDependencies() {
//     _combinedDependencies?.removeListener(_handleDependencyChanged);
//     _combinedDependencies = null;
//     _dependencies.clear();
//   }

//   void _handleDependencyChanged() {
//     final oldValue = _cache;
//     _computeAndCache();
//     if (oldValue != _cache) {
//       notifyListeners();
//     }
//   }

//   T? _cache;

//   @override
//   T get value => _cache ?? _computeAndCache();

//   final T Function(WatchFunction) _compute;

//   T _computeAndCache() {
//     _clearDependencies();

//     _cache = _compute(_watch);
//     _listenDependencies();

//     return _cache!;
//   }

//   void invalidate() => _cache = null;

//   void recompute() => _computeAndCache();

//   @override
//   void removeListener(VoidCallback listener) {
//     super.removeListener(listener);
//     if (hasListeners || !autoDispose) return;
//     dispose();
//   }

//   @override
//   void dispose() {
//     _clearDependencies();
//     super.dispose();
//   }
// }
