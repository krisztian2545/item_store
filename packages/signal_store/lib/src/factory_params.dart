import 'package:item_store/item_store.dart';

// ItemFactory with required arg and autoDispose

typedef ItemFactoryWithArgsNAD<R, A> = R Function(Ref, A, {bool autoDispose});

extension ItemFactoryWithArgsNADX<R, A> on ItemFactoryWithArgsNAD<R, A> {
  ItemFactory<R> w(A arg, {bool autoDispose = true}) => (ref) {
        (ref as LazyRef).init(
          itemFactory: this,
          args: Map.unmodifiable({
            'positioned': arg,
            'autoDispose': autoDispose,
          }),
        );

        return this(ref, arg, autoDispose: autoDispose);
      };
}

// ItemFactory with 2 required args and autoDispose

typedef ItemFactoryWithTwoArgsNAD<R, A, B> = R Function(
  Ref,
  A,
  B, {
  bool autoDispose,
});

extension ItemFactoryWithTwoArgsNADX<R, A, B>
    on ItemFactoryWithTwoArgsNAD<R, A, B> {
  ItemFactory<R> w(A arg1, B arg2, {bool autoDispose = true}) => (ref) {
        (ref as LazyRef).init(
          itemFactory: this,
          args: Map.unmodifiable({
            'positioned': List.unmodifiable([arg1, arg2]),
            'autoDispose': autoDispose,
          }),
        );

        return this(ref, arg1, arg2, autoDispose: autoDispose);
      };
}
