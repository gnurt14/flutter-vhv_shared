import 'package:flutter/material.dart';
typedef DynamicWidgetBuilder = Widget Function(Map e);
class DynamicWidgetRegistry {
  DynamicWidgetRegistry._();

  static final Map<String, DynamicWidgetBuilder> _widgets = {};

  static void register(String key, DynamicWidgetBuilder builder) {
    _widgets[key] = builder;
  }

  static DynamicWidgetBuilder? get(String key) => _widgets[key];
}