import 'package:flutter/material.dart';
import 'package:vhv_shared/vhv_shared.dart';

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  /// Path đến logo (asset, network,...)
  final String logo;
  final String? loginLogo;

  /// Builder để render logo có context
  final WidgetBuilder? logoBuilder;
  final WidgetBuilder? loginLogoBuilder;

  /// Màu viền mặc định
  final Color? borderColor;

  /// Màu text mặc định
  final Color? textColor;

  /// Màu thông báo trạng thái
  final Color? successColor;
  final Color? warningColor;
  final Color? errorColor;

  /// Style cho tiêu đề
  final TextStyle? titleStyle;

  /// Style cho tiêu đề
  final TextStyle? panelTitleStyle;
  final TextStyle? formGroupLabelStyle;

  final Color? disabledFillColor;
  final Color? linkColor;
  final double searchBarListHeight;
  final BottomSheetType bottomSheetType;


  const AppThemeExtension({
    required this.logo,
    this.loginLogo,
    this.logoBuilder,
    this.loginLogoBuilder,
    this.borderColor,
    this.textColor,
    this.successColor,
    this.warningColor,
    this.errorColor,
    this.titleStyle,
    this.panelTitleStyle = const TextStyle(
      fontSize: 16,
      height: 24/16,
      fontWeight: FontWeight.w600
    ),
    this.formGroupLabelStyle,
    this.disabledFillColor,
    this.linkColor,
    this.searchBarListHeight = 44,
    this.bottomSheetType = BottomSheetType.type2
  });

  @override
  AppThemeExtension copyWith({
    String? logo,
    String? loginLogo,
    WidgetBuilder? logoBuilder,
    WidgetBuilder? loginLogoBuilder,
    Color? borderColor,
    Color? textColor,
    Color? successColor,
    Color? warningColor,
    Color? errorColor,
    TextStyle? titleStyle,
    TextStyle? panelTitleStyle,
    TextStyle? formGroupLabelStyle,
    Color? disabledFillColor,
    Color? linkColor,
    double? searchBarListHeight,
    BorderRadius? baseBorderRadius,
    BottomSheetType? bottomSheetType
  }) {
    return AppThemeExtension(
      logo: logo ?? this.logo,
      loginLogo: loginLogo ?? this.loginLogo,
      logoBuilder: logoBuilder ?? this.logoBuilder,
      loginLogoBuilder: loginLogoBuilder ?? this.loginLogoBuilder,
      borderColor: borderColor ?? this.borderColor,
      textColor: textColor ?? this.textColor,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      errorColor: errorColor ?? this.errorColor,
      titleStyle: titleStyle ?? this.titleStyle,
      panelTitleStyle: panelTitleStyle ?? this.panelTitleStyle,
      formGroupLabelStyle: formGroupLabelStyle ?? this.formGroupLabelStyle,
      disabledFillColor: disabledFillColor ?? this.disabledFillColor,
      linkColor: linkColor ?? this.linkColor,
      searchBarListHeight: searchBarListHeight ?? this.searchBarListHeight,
      bottomSheetType: bottomSheetType ?? this.bottomSheetType,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;

    return AppThemeExtension(
      logo: t < 0.5 ? logo : other.logo,
      loginLogo: t < 0.5 ? loginLogo : other.loginLogo,
      logoBuilder: t < 0.5 ? logoBuilder : other.logoBuilder,
      loginLogoBuilder: t < 0.5 ? loginLogoBuilder : other.loginLogoBuilder,
      borderColor: Color.lerp(borderColor, other.borderColor, t),
      textColor: Color.lerp(textColor, other.textColor, t),
      successColor: Color.lerp(successColor, other.successColor, t),
      warningColor: Color.lerp(warningColor, other.warningColor, t),
      errorColor: Color.lerp(errorColor, other.errorColor, t),
      titleStyle: TextStyle.lerp(titleStyle, other.titleStyle, t),
      panelTitleStyle: TextStyle.lerp(panelTitleStyle, other.panelTitleStyle, t),
      formGroupLabelStyle: TextStyle.lerp(formGroupLabelStyle, other.formGroupLabelStyle, t),
      disabledFillColor: t < 0.5 ? disabledFillColor : other.disabledFillColor,
      linkColor: t < 0.5 ? linkColor : other.linkColor,
      searchBarListHeight: t < 0.5 ? searchBarListHeight : other.searchBarListHeight,
      bottomSheetType: t < 0.5 ? bottomSheetType : other.bottomSheetType,
    );
  }
}
