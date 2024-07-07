import 'package:flutter/foundation.dart';
import 'disposable_mixin.dart';

import 'state_notifier.dart';

extension type ReadonlyStateNotifier<T>(StateNotifier<T> _notifier)
    implements ValueListenable<T>, ObservedDisposableMixin {}
