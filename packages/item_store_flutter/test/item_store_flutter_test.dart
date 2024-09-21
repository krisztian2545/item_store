import 'package:flutter_test/flutter_test.dart';

import 'package:item_store_flutter/item_store_flutter.dart';

void main() {
  test('textController with null as initialValue and a given listener', () {
    final store = ItemStore();
    final widgetRef = WidgetRef(store: store);
    int timesListenerCalled = 0;

    final controller = widgetRef.textController(
      listener: (controller) => timesListenerCalled++,
    );
    controller.text = 'anything';

    expect(timesListenerCalled, 1);

    controller.text = 'other thing';

    expect(timesListenerCalled, 2);
  });
}
