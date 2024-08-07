import 'ref.dart';

/// Creates an item factory function which calls [RefUtilsX.bindTo] on
/// the object returned by [objectFactory].
T Function(Ref) dof<T extends Object>(T Function(Ref) objectFactory) =>
    (ref) => ref.bindTo(objectFactory(ref));
