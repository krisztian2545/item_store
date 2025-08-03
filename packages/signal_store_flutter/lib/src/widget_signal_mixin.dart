import 'package:flutter/widgets.dart';
import 'package:signals_flutter/signals_flutter.dart';

mixin WidgetSignalMixin<SF extends StatefulWidget> on State<SF> {
  late final Signal<({SF? oldWidget, SF widget})> widgetSignal =
      Signal((oldWidget: null, widget: widget));

  @override
  void didUpdateWidget(covariant oldWidget) {
    super.didUpdateWidget(oldWidget);
    widgetSignal.value = (oldWidget: oldWidget, widget: widget);
  }

  @override
  void dispose() {
    widgetSignal.dispose();
    super.dispose();
  }
}
