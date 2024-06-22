import 'package:flutter/foundation.dart';
import 'package:item_store_flutter/item_store_flutter.dart';

mixin ListenableListenerMixin {
  final _dependencies = <Listenable, VoidCallback>{};

  L listenTo<L extends Listenable>(L dependency, VoidCallback callback) {
    if (!_dependencies.containsKey(dependency)) {
      dependency.addListener(callback);
      _dependencies[dependency] = callback;
    }
    return dependency;
  }

  /// Must be called in dispose.
  @protected
  void clearDependencies() {
    for (final MapEntry(key: dependency, value: callback)
        in _dependencies.entries) {
      dependency.removeListener(callback);
    }
    _dependencies.clear();
  }
}

extension type ExposedListenableListenerMixin(ListenableListenerMixin object) {
  Map<Listenable, VoidCallback> get dependencies => object._dependencies;
}
