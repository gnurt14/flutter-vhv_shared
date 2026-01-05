part of '../extension.dart';

extension VHVSharedValueNotifierBoolExtension on ValueNotifier<bool>{
  bool get isTrue => value == true;
  bool get isFalse => value == false;
  void toggle(){
    value = !value;
  }
}