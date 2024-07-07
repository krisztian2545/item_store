import 'dart:async';

import 'package:async/async.dart';
import 'package:item_store/item_store.dart';

mixin ControllerUtils {
  final ItemStore _store = ItemStore();

  /// Executes [droppableAction] and cancels previous running tasks associated
  /// with the same [tag].
  ///
  /// Returns a [Future] that completes with the result of the [droppableAction].
  ///
  /// Example:
  ///
  ///     Future<int> loadData(int page) async {
  ///       final response = await http.get('https://example.com/page/$page');
  ///       return json.decode(response.body);
  ///     }
  ///
  ///     class MyController with ControllerUtils {
  ///       Future<List<int>> loadPage(int page) {
  ///         return droppable(
  ///           () => loadData(page),
  ///           tag: page,
  ///         );
  ///       }
  ///     }
  Future<T> droppable<T extends Object>(
    FutureOr<T> Function() droppableAction, {
    required Object tag,
  }) {
    CancelableOperation<T>? runningOperation = _store.read(tag);
    if (runningOperation != null) {
      runningOperation.cancel();
    }

    runningOperation = _store.create(
      (ref) => CancelableOperation.fromFuture(() async {
        T result;
        try {
          result = await droppableAction();
        } catch (e) {
          ref.disposeSelf();
          rethrow;
        }
        return result;
      }())
          .then(
        (value) {
          ref.disposeSelf();
          return value;
        },
      ),
      globalKey: tag,
    );

    return runningOperation!.value;
  }
}
