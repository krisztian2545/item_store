import 'package:flutter/foundation.dart';

import 'state_notifier.dart';

abstract class StateNotifierObserver {
  void onChange(StateNotifier notifier);

  void onError(StateNotifier notifier, Object error, StackTrace stackTrace);
}

class DebugStateObserver extends StateNotifierObserver {
  @override
  void onChange(StateNotifier notifier) {
    if (kDebugMode) {
      debugPrint("$notifier: ${notifier.value}");
    }
  }

  @override
  void onError(StateNotifier notifier, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint("$notifier: $error\nStackTrace: $stackTrace");
    }
  }
}
