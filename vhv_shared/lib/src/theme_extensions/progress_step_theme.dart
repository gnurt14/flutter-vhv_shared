import 'package:flutter/material.dart';

class ProgressStepTheme extends ThemeExtension<ProgressStepTheme> {
  final Color? color;
  final Color? activeColor;

  const ProgressStepTheme({
    this.color,
    this.activeColor,
  });

  @override
  ProgressStepTheme copyWith({
    Color? color,
    Color? activeColor,
  }) {
    return ProgressStepTheme(
      color: color ?? this.color,
      activeColor: activeColor ?? this.activeColor,
    );
  }

  @override
  ProgressStepTheme lerp(
      ThemeExtension<ProgressStepTheme>? other,
      double t,
      ) {
    if (other is! ProgressStepTheme) return this;

    return ProgressStepTheme(
      color: Color.lerp(color, other.color, t),
      activeColor: Color.lerp(activeColor, other.activeColor, t),
    );
  }
}