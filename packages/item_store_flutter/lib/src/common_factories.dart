import 'package:flutter/widgets.dart';
import 'package:item_store/item_store.dart';

import 'widget_ref.dart';

TextEditingController Function([
  String? initialText,
  void Function(TextEditingController controller)? listener,
]) _textControllerFactory(Ref ref) {
  return ([
    String? initialText,
    void Function(TextEditingController controller)? listener,
  ]) {
    final controller = ref.disposable(TextEditingController(text: initialText));
    if (listener != null) {
      controller.addListener(() => listener(controller));
    }
    return controller;
  };
}

TextEditingController _textEditingController(Ref ref, int tag) {
  return ref(_textControllerFactory.p());
}

extension CommonFactoriesX on WidgetRef {
  TextEditingController textController({
    Object tag = 0,
    String? initialText,
    void Function(TextEditingController controller)? listener,
  }) {
    
    return local.readValue<TextEditingController>(tag) ??
        local.writeValue(
          local(_textControllerFactory.p())(initialText, listener),
          tag: tag,
        );
  }
}
