import 'package:flutter/widgets.dart';
import 'package:item_store_flutter/item_store_flutter.dart';

class WidgetRefOnDisposeTest extends StatefulWidget {
  const WidgetRefOnDisposeTest({
    super.key,
    required this.refresher,
    required this.testObjectFactory,
  });

  final List<void Function()> refresher;
  final TestDisposableObject Function() testObjectFactory;

  @override
  State<WidgetRefOnDisposeTest> createState() => _WidgetRefOnDisposeTestState();
}

class _WidgetRefOnDisposeTestState extends State<WidgetRefOnDisposeTest>
    with WidgetRefMixin {
  int _buildCount = 0;

  @override
  void initState() {
    super.initState();

    widget.refresher.add(() => setState(() => _buildCount++));
  }

  TestDisposableObject testObjectFactory(Ref _) => widget.testObjectFactory();

  @override
  Widget build(BuildContext context) {
    print("build count: $_buildCount");

    final testObject = ref(testObjectFactory.p())..disposeWithWidget(ref);

    return const Placeholder();
  }
}

class TestDisposableObject with DisposableMixin {}
