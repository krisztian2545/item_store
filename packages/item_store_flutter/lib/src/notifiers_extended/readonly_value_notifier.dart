import 'package:flutter/foundation.dart';

extension type ReadonlyValueNotifier<T>(ValueNotifier<T> _notifier)
    implements ValueListenable<T> {
  void dispose() => _notifier.dispose();
}
