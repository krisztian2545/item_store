// import 'dart:async';

// import 'state_notifier.dart';

// typedef EventHandlerMap<T> = Map<Type, void Function(T)>;

// mixin EventControllerMixin<E, S> on StateNotifier<S> {
//   late final _eventsController = StreamController<E>()
//     ..stream.listen(_handleEvents);

//   void _handleEvents(E event) {
//     _handlers[event]?.call(event);
//   }

//   final EventHandlerMap<E> _handlers = {};

//   void on<T extends E>(void Function(T) eventHandler) {
//     _handlers[T] = eventHandler;
//   }

//   void add(E event) {
//     _eventsController.add(event);
//   }

//   @override
//   void dispose() {
//     _eventsController.close();
//     super.dispose();
//   }
// }

// sealed class CounterEvent {}

// final class IncrementCounter {}

// class Counter extends StateNotifier<int>
//     with EventControllerMixin<CounterEvent, int> {
//   Counter() : super(0);
// }
