import 'package:dotted_border/dotted_border.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
class DashedButtonStyle extends Equatable{
  final EdgeInsets padding;
  final EdgeInsets borderPadding;
  final double strokeWidth;
  final Color color;
  final Color disabledColor;
  final List<double> dashPattern;
  final Radius radius;
  final StrokeCap strokeCap;
  final PathBuilder? customPath;
  final StackFit stackFit;

  const DashedButtonStyle({
    this.color = Colors.black,
    this.disabledColor = Colors.grey,
    this.strokeWidth = 1,
    this.dashPattern = const <double>[3, 1],
    this.padding = const EdgeInsets.all(2),
    this.borderPadding = EdgeInsets.zero,
    this.radius = const Radius.circular(0),
    this.strokeCap = StrokeCap.butt,
    this.customPath,
    this.stackFit = StackFit.loose,
  });


  @override
  List<Object?> get props => [color, disabledColor, strokeWidth, dashPattern,
    padding, borderPadding, radius, strokeCap, customPath, stackFit];

  static DashedButtonStyle? lerp(DashedButtonStyle? a, DashedButtonStyle? b, double t) {
    if (a == null && b == null) return null;
    a ??= const DashedButtonStyle();
    b ??= const DashedButtonStyle();

    return DashedButtonStyle(
      color: Color.lerp(a.color, b.color, t) ?? Colors.black,
      disabledColor: Color.lerp(a.disabledColor, b.disabledColor, t) ?? Colors.grey,
      strokeWidth: lerpDouble(a.strokeWidth, b.strokeWidth, t) ?? 1.0,
      dashPattern: t < 0.5 ? a.dashPattern : b.dashPattern,
      padding: EdgeInsets.lerp(a.padding, b.padding, t) ?? const EdgeInsets.all(12),
      borderPadding: EdgeInsets.lerp(a.borderPadding, b.borderPadding, t) ?? EdgeInsets.zero,
      radius: Radius.lerp(a.radius, b.radius, t) ?? Radius.zero,
      strokeCap: t < 0.5 ? a.strokeCap : b.strokeCap,
      customPath: t < 0.5 ? a.customPath : b.customPath,
      stackFit: t < 0.5 ? a.stackFit : b.stackFit,
    );
  }

}
@immutable
class DashedButtonThemeData extends ThemeExtension<DashedButtonThemeData> {
  final DashedButtonStyle style;

  const DashedButtonThemeData({
    required this.style,
  });

  @override
  DashedButtonThemeData copyWith({
    DashedButtonStyle? style,
  }) {
    return DashedButtonThemeData(
      style: style ?? this.style,
    );
  }

  @override
  DashedButtonThemeData lerp(ThemeExtension<DashedButtonThemeData>? other, double t) {
    if (other is! DashedButtonThemeData) return this;
    return DashedButtonThemeData(
      style: DashedButtonStyle.lerp(style, other.style, t) ?? style,
    );
  }
}