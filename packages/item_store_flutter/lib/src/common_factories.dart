import 'package:flutter/widgets.dart';
import 'package:item_store/item_store.dart';

import 'widget_ref.dart';

TextEditingController textControllerProvider(
  Ref ref, [
  String? initialText,
  void Function(TextEditingController controller)? listener,
]) {
  final controller = ref.disposable(TextEditingController(text: initialText));
  if (listener != null) {
    controller.addListener(() => listener(controller));
  }
  return controller;
}

extension CommonFactoriesX on WidgetRef {
  TextEditingController textController({
    Object tag = 0,
    String? initialText,
    void Function(TextEditingController controller)? listener,
  }) {
    return local(
      textControllerProvider.p(initialText, listener),
      tag: tag,
    );
  }
}
