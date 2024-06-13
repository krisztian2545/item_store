import 'dart:async';

import 'package:item_store/item_store.dart';

mixin ControllerUtils {
  final ItemStore _store = ItemStore();

  Future<T> droppable<T extends Object>(
      FutureOr<T> Function() droppableFunction) {
    final result = _store.create((ref) => Future(droppableFunction));

    result.then((_) => _store.disposeItem(droppableFunction));
    return result;
  }
}
