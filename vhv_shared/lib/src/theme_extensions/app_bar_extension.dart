import 'package:flutter/material.dart';

class AppBarThemeExtension extends ThemeExtension<AppBarThemeExtension> {
  final AppBarThemeData? appBarTheme;
  final Widget? baseLeading;
  final Widget? baseTitle;
  final List<Widget>? baseActions;
  final bool forceMaterialTransparency;

  final Widget? flexibleSpace;

  /// Actions luôn luôn xuất hiện ở tất cả AppBar
  final List<Widget>? persistentActions;
  final Widget Function(BuildContext context)? persistentActionBuilder;

  const AppBarThemeExtension({
    this.baseLeading,
    this.baseTitle,
    this.appBarTheme,
    this.baseActions,
    this.persistentActions,
    this.persistentActionBuilder,
    this.flexibleSpace,
    this.forceMaterialTransparency = false
  });

  @override
  AppBarThemeExtension copyWith({
    AppBarThemeData? appBarTheme,
    Widget? baseLeading,
    Widget? baseTitle,
    Widget? flexibleSpace,
    List<Widget>? baseActions,
    List<Widget>? persistentActions,
    bool? forceMaterialTransparency,
    Widget Function(BuildContext context)? persistentActionBuilder,
  }) {
    return AppBarThemeExtension(
      appBarTheme: appBarTheme ?? this.appBarTheme,
      baseTitle: baseTitle ?? this.baseTitle,
      baseLeading: baseLeading ?? this.baseLeading,
      flexibleSpace: flexibleSpace ?? this.flexibleSpace,
      baseActions: baseActions ?? this.baseActions,
      persistentActions: persistentActions ?? this.persistentActions,
      persistentActionBuilder: persistentActionBuilder ?? this.persistentActionBuilder,
      forceMaterialTransparency: forceMaterialTransparency ?? this.forceMaterialTransparency,
    );
  }
  @override
  AppBarThemeExtension lerp(ThemeExtension<AppBarThemeExtension>? other, double t) {
    if (other is! AppBarThemeExtension) return this;
    return AppBarThemeExtension(
      appBarTheme: (appBarTheme != null && other.appBarTheme != null)
          ? AppBarThemeData.lerp(appBarTheme!, other.appBarTheme!, t) : other.appBarTheme,
      baseLeading: t < 0.5 ? baseLeading : other.baseLeading,
      flexibleSpace: t < 0.5 ? flexibleSpace : other.flexibleSpace,
      baseTitle: t < 0.5 ? baseTitle : other.baseTitle,
      baseActions: t < 0.5 ? baseActions : other.baseActions,
      persistentActions: t < 0.5 ? persistentActions : other.persistentActions,
      persistentActionBuilder: t < 0.5 ? persistentActionBuilder : other.persistentActionBuilder,
    );
  }
}