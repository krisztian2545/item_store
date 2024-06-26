import 'package:flutter/foundation.dart';
import 'package:item_store_flutter/src/reactive_listenable/disposable_mixin.dart';

import 'state_notifier.dart';

extension type ReadonlyStateNotifier<T>(StateNotifier<T> _notifier)
    implements ValueListenable<T>, DisposableMixin {}
