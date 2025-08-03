import 'package:flutter/widgets.dart';
import 'package:signals_flutter/signals_flutter.dart';

mixin WidgetSignalMixin<SF extends StatefulWidget> on State<SF> {
  late final Signal<SF> widgetSignal = Signal(widget);

  @override
  void didUpdateWidget(covariant oldWidget) {
    super.didUpdateWidget(oldWidget);
    widgetSignal.value = widget;
  }

  @override
  void dispose() {
    widgetSignal.dispose();
    super.dispose();
  }
}
