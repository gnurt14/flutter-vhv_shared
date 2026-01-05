import 'package:flutter/material.dart';

T? getProperties<T>(T? light, [T? dark]) {
  bool isDarkMode = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
  return isDarkMode ? dark ?? light : light;
}