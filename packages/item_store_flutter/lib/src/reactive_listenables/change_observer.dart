import 'package:flutter/foundation.dart';
import 'package:item_store_flutter/src/reactive_listenables/reactive.dart';

import 'state_notifier.dart';

abstract class ChangeObserver {
  static ChangeObserver? observer;

  void onChange(Object observedObject);

  void onError(Object observedObject, Object error, StackTrace stackTrace);
}

class DefaultChangeObserver extends ChangeObserver {
  @override
  void onChange(Object observedObject) {
    if (kDebugMode) {
      switch (observedObject) {
        case StateNotifier():
          debugPrint(
              "[StateNotifier changed] ($observedObject)${observedObject.debugLabel}: ${observedObject.value}");
        case Effect():
          debugPrint(
              "[Effect run] ($observedObject)${observedObject.debugLabel}");
        default:
          debugPrint("[Object changed] $observedObject");
      }
    }
  }

  @override
  void onError(Object observedObject, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint("[Error] $observedObject: $error\nStackTrace: $stackTrace");
    }
  }
}
