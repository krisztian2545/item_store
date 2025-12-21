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
    return ref.bindTo<T>(this, dispose: dispose, onObjectDispose: onObjectDispose);
  }
}

typedef GetSet<T> = (T Function(), void Function(T));

extension RefUtilsExtension on Ref {
  /// Binds the provided [object] to the [onDispose] callback, allowing it to be
  /// disposed when the item gets disposed.
  ///
  /// The [object] either has to have a void dispose() function, or
  /// provide a custom [dispose] function that will be called instead.
  ///
  /// Returns the provided [object].
  T disposable<T extends Object>(T object, [void Function(T)? dispose]) {
    return itemMetaData.addDisposableObject<T>(object, dispose);
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
    return itemMetaData.bindTo<T>(
      object,
      dispose: dispose,
      onObjectDispose: onObjectDispose,
      disposeFromStore: disposeSelf,
    );
  }

  /// Calls the provided function only once.
  /// If you want to use more than one function to be called once,
  /// use the [tag] to differentiate them.
  T callOnce<T>(T Function() oneOffFun, {Object? tag}) {
    return local((_) => oneOffFun(), key: (callOnce, tag));
  }

  T memo<T>(T Function() factory, List dependencies, {Object? tag}) {
    final (getMem, setMem) = data<(T, List)?>(null, tag: (memo, tag));

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

  GetSet<T> data<T>(T initialValue, {Object? tag}) {
    return local(key: (data, tag), (_) {
      T value = initialValue;
      return (() => value, (newValue) => value = newValue);
    });
  }

  // --------------------------- Dependency Tree ------------------------------

  void dependOnIfExists(Object key) {
    readItem(key)?.ref.onDispose(disposeSelf);
  }

  T? readDepByKey<T>(Object key) {
    if (!proxiedStore.contains(key)) return null;

    dependOnIfExists(key);
    return proxiedStore.readByKey<T>(key);
  }

  T? readDep<T>(ItemFactory<T> itemFactory, {Object? key}) {
    final realKey = ItemStore.keyFrom(itemFactory, key);
    if (!proxiedStore.contains(realKey)) return null;

    dependOnIfExists(realKey);
    return proxiedStore.read<T>(itemFactory, key: key);
  }

  T writeDep<T>(ItemFactory<T> itemFactory, {Object? key}) {
    final result = proxiedStore.write<T>(itemFactory, key: key);
    dependOnIfExists(ItemStore.keyFrom(itemFactory, key));
    return result;
  }

  T getDep<T>(ItemFactory<T> itemFactory, {Object? key}) {
    final result = proxiedStore.get<T>(itemFactory, key: key);
    dependOnIfExists(ItemStore.keyFrom(itemFactory, key));
    return result;
  }

  T dep<T>(ItemFactory<T> itemFactory, {Object? key}) {
    final result = proxiedStore.get<T>(itemFactory, key: key);
    dependOnIfExists(ItemStore.keyFrom(itemFactory, key));
    return result;
  }
}

extension ItemsApiUtilsExtension on ItemsApi {
  // --------------------------------- Tagged ---------------------------------

  T writet<T>(ItemFactory<T> itemFactory, Object? tag) {
    return write<T>(itemFactory, key: (itemFactory, tag));
  }

  T? readt<T>(ItemFactory<T> itemFactory, Object? tag) {
    return readByKey<T?>((itemFactory, tag));
  }

  T gett<T>(ItemFactory<T> itemFactory, Object? tag) {
    return get<T>(itemFactory, key: (itemFactory, tag));
  }

  // -------------------------------- Parameterized ---------------------------------

  T writep<T, A>(T Function(Ref, A) parameterizedFactory, A param) {
    return write<T>(key: parameterizedFactory, (ref) => parameterizedFactory(ref, param));
  }

  T getp<T, A>(T Function(Ref, A) parameterizedFactory, A param) {
    return get<T>(key: parameterizedFactory, (ref) => parameterizedFactory(ref, param));
  }

  T runp<T, A>(T Function(Ref, A) parameterizedFactory, A param) {
    return run((ref) => parameterizedFactory(ref, param));
  }

  // ------------------------ Parameterized & Tagged --------------------------

  T writept<T, A>(T Function(Ref, A) parameterizedFactory, A param) {
    return write<T>(key: (parameterizedFactory, param), (ref) => parameterizedFactory(ref, param));
  }

  T getpt<T, A>(T Function(Ref, A) parameterizedFactory, A param) {
    return get<T>(key: (parameterizedFactory, param), (ref) => parameterizedFactory(ref, param));
  }

  // ------------------------- Parameterized Factory --------------------------

  T Function(A) writepf<T, A>(T Function(Ref, A) parameterizedFactory) {
    return write<T Function(A)>(
      key: parameterizedFactory,
      (ref) =>
          (A param) => parameterizedFactory(ref, param),
    );
  }

  T Function(A)? readpf<T, A>(T Function(Ref, A) parameterizedFactory) {
    return readByKey<T Function(A)?>(parameterizedFactory);
  }

  T Function(A) getpf<T, A>(T Function(Ref, A) parameterizedFactory) {
    return write<T Function(A)>(
      key: parameterizedFactory,
      (ref) =>
          (A param) => parameterizedFactory(ref, param),
    );
  }

  /// Warning: local store won't be disposed automatically after you call the returned funcion!
  T Function(A) runpf<T, A>(T Function(Ref, A) parameterizedFactory) {
    return run<T Function(A)>(
      (ref) =>
          (A param) => parameterizedFactory(ref, param),
    );
  }

  // --------------------------------- Other ----------------------------------

  T memoItem<T>(ItemFactory<T> itemFactory, List dependencies) {
    final (getDeps, setDeps) = getpf(_memoDependenciesOf)(itemFactory);

    if (getDeps() != dependencies) {
      setDeps(dependencies);
      return write(itemFactory);
    }

    return readByKey(itemFactory);
  }
}

GetSet<List?> _memoDependenciesOf(Ref ref, Object key) {
  return ref.local(key: key, (Ref localRef) => localRef.data<List?>(null));
}

ItemStore localStoreFactory(Ref ref) => ref.local;
