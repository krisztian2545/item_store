import 'package:flutter/widgets.dart';
import 'package:item_store/item_store.dart';

import 'widget_ref.dart';

TextEditingController _textControllerFactory([
  String? initialText,
  void Function(TextEditingController controller)? listener,
]) {
  final controller = TextEditingController(text: initialText);
  if (listener != null) {
    controller.addListener(() => listener(controller));
  }
  return controller;
}

TextEditingController Function({
  Object tag,
  String? initialText,
  void Function(TextEditingController controller)? listener,
}) textEditingControllerContainer(Ref ref) {
  return ({tag = 0, initialText, listener}) {
    return ref.local<TextEditingController>(
      key: (TextEditingController, tag),
      (localRef) =>
          _textControllerFactory(initialText, listener)..disposeWith(localRef),
    );
  };
}

extension CommonFactoriesX on WidgetRef {
  TextEditingController textController({
    Object tag = 0,
    String? initialText,
    void Function(TextEditingController controller)? listener,
  }) {
    return local(textEditingControllerContainer)(
      tag: tag,
      initialText: initialText,
      listener: listener,
    );
  }
}
