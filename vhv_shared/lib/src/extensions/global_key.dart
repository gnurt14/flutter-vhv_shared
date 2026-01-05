part of '../extension.dart';

extension FoundationGlobalKeyExtension on GlobalKey{
  GlobalKey sizeWidget(Function(Size) onGetSize){
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RenderObject? obj = globalContext.findRenderObject();
      bool isBox = obj is RenderBox;
      if (isBox) {
        RenderBox box = obj;
        onGetSize(box.size);
      }
    });
    return this;
  }
}