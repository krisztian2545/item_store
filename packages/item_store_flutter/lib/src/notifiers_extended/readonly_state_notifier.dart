import 'package:flutter/foundation.dart';

import 'state_notifier.dart';

extension type ReadonlyStateNotifier<T>(StateNotifier<T> _notifier)
    implements ValueListenable<T> {
  void dispose() => _notifier.dispose();
}
