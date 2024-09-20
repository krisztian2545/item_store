import 'package:item_store/item_store.dart';

typedef ItemFactory<R> = R Function(Ref);

// ItemFactory with required args

typedef ItemFactoryWithArgs<R, A> = R Function(Ref, A);

extension ItemFactoryWithArgsX<R, A> on ItemFactoryWithArgs<R, A> {
  ItemFactory<R> w(A arg) => (ref) {
        (ref as LazyRef).init(itemFactory: this, args: arg);

        return this(ref, arg);
      };
}

// ItemFactory with optional args

typedef ItemFactoryWithOpArgs<R, A> = R Function(Ref, [A]);

extension ItemFactoryWithOpArgsX<R, A> on ItemFactoryWithOpArgs<R, A> {
  ItemFactory<R> w([A? arg]) => (ref) {
        (ref as LazyRef).init(itemFactory: this, args: arg);

        return arg == null ? this(ref) : this(ref, arg);
      };
}

// ItemFactory with 2 required args

typedef ItemFactoryWithTwoArgs<R, A, B> = R Function(Ref, A, B);

extension ItemFactoryWithTwoArgsX<R, A, B> on ItemFactoryWithTwoArgs<R, A, B> {
  ItemFactory<R> w(A arg1, B arg2) => (ref) {
        (ref as LazyRef).init(
          itemFactory: this,
          args: List.unmodifiable([arg1, arg2]),
        );

        return this(ref, arg1, arg2);
      };
}

// ItemFactory with a required arg and an optional arg

typedef ItemFactoryWithArgNOpArg<R, A, B> = R Function(Ref, A, [B]);

extension ItemFactoryWithArgNOpArgX<R, A, B>
    on ItemFactoryWithArgNOpArg<R, A, B> {
  ItemFactory<R> w(A arg1, [B? arg2]) => (ref) {
        (ref as LazyRef).init(
          itemFactory: this,
          args: List.unmodifiable([arg1, arg2]),
        );

        if (arg2 == null) {
          return this(ref, arg1);
        }

        return this(ref, arg1, arg2);
      };
}

// ItemFactory with a required arg and an optional arg

typedef ItemFactoryWithTwoOpArg<R, A, B> = R Function(Ref, [A, B]);

extension ItemFactoryWithTwoOpArgX<R, A, B>
    on ItemFactoryWithTwoOpArg<R, A, B> {
  ItemFactory<R> w([A? arg1, B? arg2]) => (ref) {
        (ref as LazyRef).init(
          itemFactory: this,
          args: List.unmodifiable([arg1, arg2]),
        );

        if (arg1 == null) {
          if (arg2 == null) return this(ref);

          return this(ref, arg1 as A, arg2);
        }

        if (arg2 == null) {
          return this(ref, arg1);
        }

        return this(ref, arg1, arg2);
      };
}
