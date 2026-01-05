part of '../extension.dart';
extension VHVBrightnessExtension on Brightness {
  Brightness get reversed =>
      this == Brightness.dark ? Brightness.light : Brightness.dark;
}
