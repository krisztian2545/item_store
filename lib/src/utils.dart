import 'package:item_store/item_store.dart';

/// Creates an item factory function which calls [RefUtilsX.bindTo] on
/// the object returned by [objectFactory].
T Function(Ref) dof<T extends Object>(T Function(Ref) objectFactory) =>
    (ref) => ref.bindTo(objectFactory(ref));

extension ObjectUtilsForRefX<T extends Object> on T {
  T disposeWith(Ref ref, [void Function(T)? dispose]) {
    return ref.disposable<T>(this, dispose);
  }

  T bindTo(
    Ref ref, {
    void Function(T)? dispose,
    void Function(void Function() disposeItemFromStore)? onObjectDispose,
  }) {
    return ref.bindTo<T>(
      this,
      dispose: dispose,
      onObjectDispose: onObjectDispose,
    );
  }
}

extension RefUtilsExtension on Ref {
  /// Binds the provided [object] to the [onDispose] callback, allowing it to be
  /// disposed when the item gets disposed.
  ///
  /// The [object] either has to have a void dispose() function, or
  /// provide a custom [dispose] function that will be called instead.
  ///
  /// Returns the provided [object].
  T disposable<T extends Object>(T object, [void Function(T)? dispose]) {
    return itemMetaData.safeAddDisposableObject<T>(object, dispose);
  }

  /// Bind the given [object] object to this ref, meaning if any of them gets disposed,
  /// both of them will be disposed.
  ///
  /// [object] must have:
  /// - a void dispose() function or provide [disposeObject],
  /// - a void onDispose(void Function()) function or provide [onObjectDispose].
  ///
  /// See also:
  /// - [disposable] for one way binding,
  /// - [DisposableMixin] to add the required functions to your class.
  T bindTo<T extends Object>(
    T object, {
    void Function(T)? dispose,
    void Function(void Function())? onObjectDispose,
  }) {
    return itemMetaData.safeBindTo<T>(
      object,
      dispose: dispose,
      onObjectDispose: onObjectDispose,
      disposeFromStore: disposeSelf,
    );
  }

  /// Calls the provided function only once.
  /// If you want to use more than one function to be called once,
  /// use the [tag] to differentiate them.
  void callOnce(Function() oneOffFun, {Object? tag}) {
    local((_) => oneOffFun(), key: (callOnce, tag));
  }

  T memo<T>(T Function() factory, Set dependencies, {Object? tag}) {
    final (getMem, setMem) = data<(T, Set)?>(null, tag: tag);

    T update() {
      final value = factory();
      setMem((value, dependencies));
      return value;
    }

    final mem = getMem();
    if (mem == null) {
      return update();
    }

    final (oldValue, oldDependecies) = mem;
    if (oldDependecies != dependencies) {
      return update();
    }

    return oldValue;
  }

  (T Function(), void Function(T)) data<T>(T initialValue, {Object? tag}) {
    return local(key: (data, tag), (_) {
      T value = initialValue;
      return (() => value, (newValue) => value = newValue);
    });
  }
}

extension ItemsApiUtilsExtension on ItemsApi {
  T tagged<T>(ItemFactory<T> itemFactory, Object? tag) {
    return get<T>(itemFactory, key: (itemFactory, tag));
  }

  T Function(A) paramf<T, A>(T Function(Ref, A) parameterizedFactory) {
    return get<T Function(A)>(
      key: parameterizedFactory,
      (ref) => (param) => parameterizedFactory(ref, param),
    );
  }

  T pnt<T, A>(T Function(Ref, A) parameterizedFactory, A param) {
    return get<T>(
      key: (parameterizedFactory, param),
      (ref) => parameterizedFactory(ref, param),
    );
  }
}
