import 'package:item_store/item_store.dart';

typedef ItemFactory<R> = R Function(Ref);

// ItemFactory with required args

typedef ItemFactoryWithArgs<R, A> = R Function(Ref, A);

extension ItemFactoryWithArgsX<R, A> on ItemFactoryWithArgs<R, A> {
  ItemFactory<R> w(A args) => (ref) {
        (ref as LazyRef).init(itemFactory: this, args: args);

        return this(ref, args);
      };
}

// ItemFactory with optional args

typedef ItemFactoryWithOpArgs<R, A> = R Function(Ref, [A]);

extension ItemFactoryWithOpArgsX<R, A> on ItemFactoryWithOpArgs<R, A> {
  ItemFactory<R> w([A? args]) => (ref) {
        (ref as LazyRef).init(itemFactory: this, args: args);

        return args == null ? this(ref) : this(ref, args);
      };
}
