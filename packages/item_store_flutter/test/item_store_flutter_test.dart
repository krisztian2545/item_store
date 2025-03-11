import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:item_store_flutter/item_store_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'widget_ref_on_dispose_test_widget.dart';

@GenerateNiceMocks([MockSpec<TestDisposableObject>()])
import 'item_store_flutter_test.mocks.dart';

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

  testWidgets(
    'disposeWithWidget registers dispose callback only once',
    (tester) async {
      final refresher = <void Function()>[];
      late final TestDisposableObject testObject;
      await tester.pumpWidget(
        ItemStoreProvider(
          child: WidgetRefOnDisposeTest(
            refresher: refresher,
            testObjectFactory: () {
              testObject = MockTestDisposableObject();
              return testObject;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // force calling build multiple times
      await tester.runAsync(() async {
        for (int i = 0; i < 5; i++) {
          refresher[0]();
          await tester.pumpAndSettle();
        }
      });

      await tester.pumpWidget(const Placeholder());

      verify(testObject.dispose()).called(1);
    },
  );
}
