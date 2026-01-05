import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:vhv_shared/src/theme/app_colors.dart';

class CircleButton extends ButtonStyleButton{
  const CircleButton({
    super.key,
    required super.onPressed,
    super.onLongPress,
    super.onHover,
    super.onFocusChange,
    super.style,
    super.focusNode,
    super.autofocus = false,
    super.clipBehavior,
    super.statesController,
    required super.child,
    super.iconAlignment,
  });
  @protected
  RoundedRectangleBorder get defaultShape =>
      const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(80)));
  factory CircleButton.icon({
    Key? key,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    ValueChanged<bool>? onHover,
    ValueChanged<bool>? onFocusChange,
    ButtonStyle? style,
    FocusNode? focusNode,
    bool? autofocus,
    Clip? clipBehavior,
    WidgetStatesController? statesController,
    Widget? icon,
    required Widget label,
    IconAlignment iconAlignment = IconAlignment.start,
  }) {
    return CircleButton(
      key: key,
      onPressed: onPressed,
      onLongPress: onLongPress,
      onHover: onHover,
      onFocusChange: onFocusChange,
      style: style,
      focusNode: focusNode,
      autofocus: autofocus ?? false,
      clipBehavior: clipBehavior,
      child: icon == null ? label : _CircleButtonWithIconChild(
        icon: icon,
        label: label,
        buttonStyle: style,
        iconAlignment: iconAlignment,
      ),
    );
  }
  factory CircleButton.dashed({
    Key? key,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    ValueChanged<bool>? onHover,
    ValueChanged<bool>? onFocusChange,
    ButtonStyle? style,
    FocusNode? focusNode,
    bool? autofocus,
    Clip? clipBehavior,
    WidgetStatesController? statesController,
    bool isGray = false,
    required Widget child,
  }){
    return _CircleButtonDashed(
      key: key,
      onPressed: onPressed,
      onLongPress: onLongPress,
      onHover: onHover,
      style: style,
      onFocusChange: onFocusChange,
      focusNode: focusNode,
      autofocus: autofocus ?? false,
      clipBehavior: clipBehavior,
      statesController: statesController,
      isGray: isGray,
      child: child,
    );
  }
  factory CircleButton.dashedIcon({
    Key? key,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    ValueChanged<bool>? onHover,
    ValueChanged<bool>? onFocusChange,
    ButtonStyle? style,
    FocusNode? focusNode,
    bool? autofocus,
    Clip? clipBehavior,
    WidgetStatesController? statesController,
    required Widget label,
    Widget? icon,
    IconAlignment iconAlignment = IconAlignment.start,
    bool isGray = false,
  }){
    return _CircleButtonDashed(
      key: key,
      onPressed: onPressed,
      onLongPress: onLongPress,
      onHover: onHover,
      style: style,
      onFocusChange: onFocusChange,
      focusNode: focusNode,
      autofocus: autofocus ?? false,
      clipBehavior: clipBehavior,
      statesController: statesController,
      isGray: isGray,
      child: icon == null ? label : _CircleButtonWithIconChild(
        buttonStyle: style,
        icon: icon,
        label: label,
        iconAlignment: iconAlignment,
      )
    );
  }

  factory CircleButton.outlined({
    Key? key,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    ValueChanged<bool>? onHover,
    ValueChanged<bool>? onFocusChange,
    ButtonStyle? style,
    FocusNode? focusNode,
    bool? autofocus,
    Clip? clipBehavior,
    WidgetStatesController? statesController,
    bool isGray = false,
    required Widget child,
  }){
    return _CircleButtonOutlined(
      key: key,
      onPressed: onPressed,
      onLongPress: onLongPress,
      onHover: onHover,
      style: style,
      onFocusChange: onFocusChange,
      focusNode: focusNode,
      autofocus: autofocus ?? false,
      clipBehavior: clipBehavior,
      statesController: statesController,
      isGray: isGray,
      child: child,
    );
  }
factory CircleButton.outlinedIcon({
    Key? key,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    ValueChanged<bool>? onHover,
    ValueChanged<bool>? onFocusChange,
    ButtonStyle? style,
    FocusNode? focusNode,
    bool? autofocus,
    Clip? clipBehavior,
    WidgetStatesController? statesController,
    bool isGray = false,
    required Widget label,
    Widget? icon,
    IconAlignment iconAlignment = IconAlignment.start
  }){
    return _CircleButtonOutlined(
      key: key,
      onPressed: onPressed,
      onLongPress: onLongPress,
      onHover: onHover,
      style: style,
      onFocusChange: onFocusChange,
      focusNode: focusNode,
      autofocus: autofocus ?? false,
      clipBehavior: clipBehavior,
      statesController: statesController,
      isGray: isGray,
      child: icon == null ? label : _CircleButtonWithIconChild(
        buttonStyle: style,
        icon: icon,
        label: label,
        iconAlignment: iconAlignment,
      )
    );
  }

  factory CircleButton.text({
    Key? key,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    ValueChanged<bool>? onHover,
    ValueChanged<bool>? onFocusChange,
    ButtonStyle? style,
    FocusNode? focusNode,
    bool? autofocus,
    Clip? clipBehavior,
    WidgetStatesController? statesController,
    required Widget child,
  }){
    return _CircleButtonText(
      key: key,
      onPressed: onPressed,
      onLongPress: onLongPress,
      onHover: onHover,
      style: style,
      onFocusChange: onFocusChange,
      focusNode: focusNode,
      autofocus: autofocus ?? false,
      clipBehavior: clipBehavior,
      statesController: statesController,
      child: child,
    );
  }
  factory CircleButton.textIcon({
    Key? key,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    ValueChanged<bool>? onHover,
    ValueChanged<bool>? onFocusChange,
    ButtonStyle? style,
    FocusNode? focusNode,
    bool? autofocus,
    Clip? clipBehavior,
    WidgetStatesController? statesController,
    required Widget label,
    Widget? icon,
    IconAlignment iconAlignment = IconAlignment.start
  }){
    return _CircleButtonText(
        key: key,
        onPressed: onPressed,
        onLongPress: onLongPress,
        onHover: onHover,
        style: style,
        onFocusChange: onFocusChange,
        focusNode: focusNode,
        autofocus: autofocus ?? false,
        clipBehavior: clipBehavior,
        statesController: statesController,
        child: icon == null ? label : _CircleButtonWithIconChild(
          buttonStyle: style,
          icon: icon,
          label: label,
          iconAlignment: iconAlignment,
        )
    );
  }

  factory CircleButton.secondary({
    Key? key,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    ValueChanged<bool>? onHover,
    ValueChanged<bool>? onFocusChange,
    ButtonStyle? style,
    FocusNode? focusNode,
    bool? autofocus,
    Clip? clipBehavior,
    WidgetStatesController? statesController,
    required Widget child,
  }){
    return _CircleButtonSecondary(
      key: key,
      onPressed: onPressed,
      onLongPress: onLongPress,
      onHover: onHover,
      style: style,
      onFocusChange: onFocusChange,
      focusNode: focusNode,
      autofocus: autofocus ?? false,
      clipBehavior: clipBehavior,
      statesController: statesController,
      child: child,
    );
  }
  factory CircleButton.secondaryIcon({
    Key? key,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    ValueChanged<bool>? onHover,
    ValueChanged<bool>? onFocusChange,
    ButtonStyle? style,
    FocusNode? focusNode,
    bool? autofocus,
    Clip? clipBehavior,
    WidgetStatesController? statesController,
    required Widget label,
    Widget? icon,
    IconAlignment iconAlignment = IconAlignment.start
  }){
    return _CircleButtonSecondary(
        key: key,
        onPressed: onPressed,
        onLongPress: onLongPress,
        onHover: onHover,
        style: style,
        onFocusChange: onFocusChange,
        focusNode: focusNode,
        autofocus: autofocus ?? false,
        clipBehavior: clipBehavior,
        statesController: statesController,
        child: icon == null ? label : _CircleButtonWithIconChild(
          buttonStyle: style,
          icon: icon,
          label: label,
          iconAlignment: iconAlignment,
        )
    );
  }

  factory CircleButton.destruction({
    Key? key,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    ValueChanged<bool>? onHover,
    ValueChanged<bool>? onFocusChange,
    ButtonStyle? style,
    FocusNode? focusNode,
    bool? autofocus,
    Clip? clipBehavior,
    WidgetStatesController? statesController,
    required Widget child,
  }){
    return _CircleButtonDestruction(
      key: key,
      onPressed: onPressed,
      onLongPress: onLongPress,
      onHover: onHover,
      style: style,
      onFocusChange: onFocusChange,
      focusNode: focusNode,
      autofocus: autofocus ?? false,
      clipBehavior: clipBehavior,
      statesController: statesController,
      child: child,
    );
  }
  factory CircleButton.destructionIcon({
    Key? key,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    ValueChanged<bool>? onHover,
    ValueChanged<bool>? onFocusChange,
    ButtonStyle? style,
    FocusNode? focusNode,
    bool? autofocus,
    Clip? clipBehavior,
    WidgetStatesController? statesController,
    required Widget label,
    Widget? icon,
    IconAlignment iconAlignment = IconAlignment.start
  }){
    return _CircleButtonDestruction(
        key: key,
        onPressed: onPressed,
        onLongPress: onLongPress,
        onHover: onHover,
        style: style,
        onFocusChange: onFocusChange,
        focusNode: focusNode,
        autofocus: autofocus ?? false,
        clipBehavior: clipBehavior,
        statesController: statesController,
        child: icon == null ? label : _CircleButtonWithIconChild(
          buttonStyle: style,
          icon: icon,
          label: label,
          iconAlignment: iconAlignment,
        )
    );
  }
  @override
  ButtonStyle defaultStyleOf(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return styleFrom(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
      disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
      shadowColor: theme.shadowColor,
      elevation: 0,
      textStyle: theme.textTheme.labelLarge,
      padding: _scaledPadding(context),
      minimumSize: const Size(64, 36),
      fixedSize: const Size.fromHeight(40),
      maximumSize: Size.infinite,
      shape: defaultShape,
      enabledMouseCursor: SystemMouseCursors.click,
      disabledMouseCursor: SystemMouseCursors.basic,
      visualDensity: theme.visualDensity,
      tapTargetSize: theme.materialTapTargetSize,
      animationDuration: kThemeChangeDuration,
      enableFeedback: true,
      alignment: Alignment.center,
      splashFactory: InkRipple.splashFactory,
    );
  }

  /// Returns the [CircleButtonThemeData.style] of the closest
  /// [CircleButtonTheme] ancestor.
  @override
  ButtonStyle? themeStyleOf(BuildContext context) {
    return ElevatedButtonTheme.of(context).style?.copyWith(
      side: WidgetStateProperty.resolveWith<BorderSide?>((state){
        if(state.contains(WidgetState.disabled)){
          return BorderSide(color: AppColors.gray[200]!);
        }
        return null;
      }),
      shape: WidgetStateProperty.resolveWith<OutlinedBorder?>((state){
        return defaultShape;
      })

    );
  }

  static ButtonStyle styleFrom({
    Color? foregroundColor,
    Color? backgroundColor,
    Color? disabledForegroundColor,
    Color? disabledBackgroundColor,
    Color? shadowColor,
    Color? surfaceTintColor,
    Color? iconColor,
    Color? disabledIconColor,
    Color? overlayColor,
    double? elevation,
    TextStyle? textStyle,
    EdgeInsetsGeometry? padding,
    Size? minimumSize,
    Size? fixedSize,
    Size? maximumSize,
    BorderSide? side,
    OutlinedBorder? shape,
    MouseCursor? enabledMouseCursor,
    MouseCursor? disabledMouseCursor,
    VisualDensity? visualDensity,
    MaterialTapTargetSize? tapTargetSize,
    Duration? animationDuration,
    bool? enableFeedback,
    AlignmentGeometry? alignment,
    InteractiveInkFeatureFactory? splashFactory,
    ButtonLayerBuilder? backgroundBuilder,
    ButtonLayerBuilder? foregroundBuilder,
  }) {
    final WidgetStateProperty<Color?>? foregroundColorProp = switch ((foregroundColor, disabledForegroundColor)) {
      (null, null) => null,
      (_, _) => _CircleButtonDefaultColor(foregroundColor, disabledForegroundColor),
    };
    final WidgetStateProperty<Color?>? backgroundColorProp = switch ((backgroundColor, disabledBackgroundColor)) {
      (null, null) => null,
      (_, _) => _CircleButtonDefaultColor(backgroundColor, disabledBackgroundColor),
    };
    final WidgetStateProperty<Color?>? iconColorProp = switch ((iconColor, disabledIconColor)) {
      (null, null) => null,
      (_, _) => _CircleButtonDefaultColor(iconColor, disabledIconColor),
    };
    final WidgetStateProperty<Color?>? overlayColorProp = switch ((foregroundColor, overlayColor)) {
      (null, null) => null,
      (_, final Color overlayColor) when overlayColor.toARGB32() == 0 => const WidgetStatePropertyAll<Color?>(Colors.transparent),
      (_, _) => _CircleButtonDefaultOverlay((overlayColor ?? foregroundColor)!),
    };
    final WidgetStateProperty<double>? elevationValue = switch (elevation) {
      null => null,
      _ => _CircleButtonDefaultElevation(elevation),
    };
    final WidgetStateProperty<MouseCursor?> mouseCursor = _CircleButtonDefaultMouseCursor(enabledMouseCursor, disabledMouseCursor);

    return ButtonStyle(
      textStyle: WidgetStatePropertyAll<TextStyle?>(textStyle),
      backgroundColor: backgroundColorProp,
      foregroundColor: foregroundColorProp,
      overlayColor: overlayColorProp,
      shadowColor: ButtonStyleButton.allOrNull<Color>(shadowColor),
      surfaceTintColor: ButtonStyleButton.allOrNull<Color>(surfaceTintColor),
      iconColor: iconColorProp,
      elevation: elevationValue,
      padding: ButtonStyleButton.allOrNull<EdgeInsetsGeometry>(padding),
      minimumSize: ButtonStyleButton.allOrNull<Size>(minimumSize),
      fixedSize: ButtonStyleButton.allOrNull<Size>(fixedSize),
      maximumSize: ButtonStyleButton.allOrNull<Size>(maximumSize),
      side: ButtonStyleButton.allOrNull<BorderSide>(side),
      shape: ButtonStyleButton.allOrNull<OutlinedBorder>(shape),
      mouseCursor: mouseCursor,
      visualDensity: visualDensity,
      tapTargetSize: tapTargetSize,
      animationDuration: animationDuration,
      enableFeedback: enableFeedback,
      alignment: alignment,
      splashFactory: splashFactory,
      backgroundBuilder: backgroundBuilder,
      foregroundBuilder: foregroundBuilder,
    );
  }

}

class _CircleButtonWithIconChild extends StatelessWidget {
  const _CircleButtonWithIconChild({
    required this.label,
    required this.icon,
    required this.buttonStyle,
    required this.iconAlignment,
  });

  final Widget label;
  final Widget icon;
  final ButtonStyle? buttonStyle;
  final IconAlignment iconAlignment;

  @override
  Widget build(BuildContext context) {
    final double defaultFontSize = buttonStyle?.textStyle?.resolve(const <WidgetState>{})?.fontSize ?? 14.0;
    final double scale = clampDouble(MediaQuery.textScalerOf(context).scale(defaultFontSize) / 14.0, 1.0, 2.0) - 1.0;
    final double gap = lerpDouble(8, 4, scale)!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: iconAlignment == IconAlignment.start
          ? <Widget>[icon, SizedBox(width: gap), Flexible(child: label)]
          : <Widget>[Flexible(child: label), SizedBox(width: gap), icon],
    );
  }
}
class _CircleButtonOutlined extends CircleButton {
  const _CircleButtonOutlined({
    super.key,
    required super.onPressed,
    super.onLongPress,
    super.onHover,
    super.onFocusChange,
    super.style,
    super.focusNode,
    super.autofocus,
    super.clipBehavior,
    super.statesController,
    super.child,
    this.isGray = false
  });
  final bool isGray;
  @override
  ButtonStyle defaultStyleOf(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return CircleButton.styleFrom(
      foregroundColor: colorScheme.primary,
      disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
      backgroundColor: Colors.transparent,
      disabledBackgroundColor: Colors.transparent,
      shadowColor: theme.shadowColor,
      elevation: 0,
      textStyle: theme.textTheme.labelLarge,
      padding: _scaledPadding(context),
      minimumSize: const Size(64, 36),
      fixedSize: const Size.fromHeight(40),
      maximumSize: Size.infinite,
      side: isGray ? BorderSide(color: AppColors.gray[300]!) : null,
      shape: defaultShape,
      enabledMouseCursor: SystemMouseCursors.click,
      disabledMouseCursor: SystemMouseCursors.basic,
      visualDensity: theme.visualDensity,
      tapTargetSize: theme.materialTapTargetSize,
      animationDuration: kThemeChangeDuration,
      enableFeedback: true,
      alignment: Alignment.center,
      splashFactory: InkRipple.splashFactory,
    );
  }

  @override
  ButtonStyle? themeStyleOf(BuildContext context) {
    return OutlinedButtonTheme.of(context).style?.copyWith(
      side: isGray ? WidgetStateProperty.resolveWith<BorderSide?>((state){
        if(state.contains(WidgetState.disabled)){
          return BorderSide(color: AppColors.gray[200]!);
        }
        return BorderSide(color: AppColors.gray[300]!);
      }) : null,

      shape: WidgetStateProperty.resolveWith<OutlinedBorder?>((state){
        return defaultShape;
      }),

      backgroundColor: WidgetStateProperty.resolveWith<Color?>((state){
        if(state.contains(WidgetState.disabled)){
          return Colors.transparent;
        }
        return null;
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>((state){
        if(state.contains(WidgetState.disabled)){
          return AppColors.gray[500];
        }
        return null;
      }),
      elevation: WidgetStateProperty.resolveWith<double?>((state){
        return 0;
      })
    );
  }
}
class _CircleButtonDashed extends CircleButton {
  const _CircleButtonDashed({
    super.key,
    required super.onPressed,
    super.onLongPress,
    super.onHover,
    super.onFocusChange,
    super.style,
    super.focusNode,
    super.autofocus,
    super.clipBehavior,
    super.statesController,
    super.child,
    this.isGray = false
  });
  final bool isGray;
  @override
  ButtonStyle defaultStyleOf(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return CircleButton.styleFrom(
      foregroundColor: colorScheme.primary,
      disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
      backgroundColor: Colors.transparent,
      disabledBackgroundColor: Colors.transparent,
      shadowColor: theme.shadowColor,
      elevation: 0,
      textStyle: theme.textTheme.labelLarge,
      padding: _scaledPadding(context),
      minimumSize: const Size(64, 36),
      fixedSize: const Size.fromHeight(40),
      maximumSize: Size.infinite,
      side: BorderSide.none,
      shape: defaultShape,
      enabledMouseCursor: SystemMouseCursors.click,
      disabledMouseCursor: SystemMouseCursors.basic,
      visualDensity: theme.visualDensity,
      tapTargetSize: theme.materialTapTargetSize,
      animationDuration: kThemeChangeDuration,
      enableFeedback: true,
      alignment: Alignment.center,
      splashFactory: InkRipple.splashFactory,
    );
  }

  @override
  ButtonStyle? themeStyleOf(BuildContext context) {
    return OutlinedButtonTheme.of(context).style?.copyWith(
      side: WidgetStateProperty.resolveWith<BorderSide?>((state){
        return BorderSide.none;
      }),

      shape: WidgetStateProperty.resolveWith<OutlinedBorder?>((state){
        return defaultShape;
      }),
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((state){
        if(state.contains(WidgetState.disabled)){
          return Colors.transparent;
        }
        return null;
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>((state){
        if(state.contains(WidgetState.disabled)){
          return AppColors.gray[500];
        }
        return null;
      }),
      elevation: WidgetStateProperty.resolveWith<double?>((state){
        return 0;
      }),
      backgroundBuilder: (_, state, child){
        Color color = isGray ? AppColors.gray[300]! : AppColors.primary;
        if(state.contains(WidgetState.disabled)){
          color = AppColors.gray[200]!;
        }
        return Center(
          child: DottedBorder(
            options: RoundedRectDottedBorderOptions(
              radius: const Radius.circular(80),
              dashPattern: const [3, 3],
              color: color,
              padding: EdgeInsets.zero,
              borderPadding: const EdgeInsets.all(1),
            ),
            child: Center(
              child: ClipRRect(
                borderRadius: defaultShape.borderRadius,
                child: child!,
              ),
            ),
          ),
        );
      }
    );
  }
}
class _CircleButtonText extends CircleButton {
  const _CircleButtonText({
    super.key,
    required super.onPressed,
    super.onLongPress,
    super.onHover,
    super.onFocusChange,
    super.style,
    super.focusNode,
    super.autofocus,
    super.clipBehavior,
    super.statesController,
    super.child,
  });
  @override
  ButtonStyle defaultStyleOf(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return CircleButton.styleFrom(
      foregroundColor: colorScheme.primary,
      disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
      backgroundColor: Colors.transparent,
      disabledBackgroundColor: Colors.transparent,
      shadowColor: theme.shadowColor,
      elevation: 0,
      textStyle: theme.textTheme.labelLarge,
      padding: _scaledPadding(context),
      minimumSize: const Size(64, 36),
      fixedSize: const Size.fromHeight(40),
      maximumSize: Size.infinite,
      side: BorderSide.none,
      shape: defaultShape,
      enabledMouseCursor: SystemMouseCursors.click,
      disabledMouseCursor: SystemMouseCursors.basic,
      visualDensity: theme.visualDensity,
      tapTargetSize: theme.materialTapTargetSize,
      animationDuration: kThemeChangeDuration,
      enableFeedback: true,
      alignment: Alignment.center,
      splashFactory: InkRipple.splashFactory,
    );
  }

  @override
  ButtonStyle? themeStyleOf(BuildContext context) {
    return OutlinedButtonTheme.of(context).style?.copyWith(
      side: WidgetStateProperty.resolveWith<BorderSide?>((state){
        if(state.contains(WidgetState.disabled)){
          return BorderSide.none;
        }
        return BorderSide.none;
      }),

      shape: WidgetStateProperty.resolveWith<OutlinedBorder?>((state){
        return defaultShape;
      }),

      backgroundColor: WidgetStateProperty.resolveWith<Color?>((state){
        if(state.contains(WidgetState.disabled)){
          return Colors.transparent;
        }
        return null;
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>((state){
        if(state.contains(WidgetState.disabled)){
          return AppColors.gray[500];
        }
        return null;
      }),
    );
  }
}

class _CircleButtonSecondary extends CircleButton {
  const _CircleButtonSecondary({
    super.key,
    required super.onPressed,
    super.onLongPress,
    super.onHover,
    super.onFocusChange,
    super.style,
    super.focusNode,
    super.autofocus,
    super.clipBehavior,
    super.statesController,
    super.child,
  });
  @override
  ButtonStyle defaultStyleOf(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return CircleButton.styleFrom(
      foregroundColor: colorScheme.primary,
      disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
      backgroundColor: Colors.transparent,
      disabledBackgroundColor: Colors.transparent,
      shadowColor: theme.shadowColor,
      elevation: 0,
      textStyle: theme.textTheme.labelLarge,
      padding: _scaledPadding(context),
      minimumSize: const Size(64, 36),
      fixedSize: const Size.fromHeight(40),
      maximumSize: Size.infinite,
      side: BorderSide.none,
      shape: defaultShape,
      enabledMouseCursor: SystemMouseCursors.click,
      disabledMouseCursor: SystemMouseCursors.basic,
      visualDensity: theme.visualDensity,
      tapTargetSize: theme.materialTapTargetSize,
      animationDuration: kThemeChangeDuration,
      enableFeedback: true,
      alignment: Alignment.center,
      splashFactory: InkRipple.splashFactory,
    );
  }

  @override
  ButtonStyle? themeStyleOf(BuildContext context) {
    return OutlinedButtonTheme.of(context).style?.copyWith(
      side: WidgetStateProperty.resolveWith<BorderSide?>((state){
        if(state.contains(WidgetState.disabled)){
          return BorderSide.none;
        }
        return BorderSide.none;
      }),

      shape: WidgetStateProperty.resolveWith<OutlinedBorder?>((state){
        return defaultShape;
      }),

      backgroundColor: WidgetStateProperty.resolveWith<Color?>((state){
        if(state.contains(WidgetState.disabled)){
          return AppColors.gray[200];
        }
        if(!state.contains(WidgetState.pressed)){
          return AppColors.primary.withValues(alpha: 0.15);
        }
        if(state.contains(WidgetState.pressed)){
          return AppColors.primary.withValues(alpha: 0.15);
        }
        return null;
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>((state){
        if(state.contains(WidgetState.disabled)){
          return AppColors.gray[500];
        }
        if(!state.contains(WidgetState.pressed)){
          return AppColors.primary;
        }
        return null;
      }),
    );
  }
}

class _CircleButtonDestruction extends CircleButton {
  const _CircleButtonDestruction({
    super.key,
    required super.onPressed,
    super.onLongPress,
    super.onHover,
    super.onFocusChange,
    super.style,
    super.focusNode,
    super.autofocus,
    super.clipBehavior,
    super.statesController,
    super.child,
  });
  @override
  ButtonStyle defaultStyleOf(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return CircleButton.styleFrom(
      foregroundColor: colorScheme.primary,
      disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
      backgroundColor: Colors.transparent,
      disabledBackgroundColor: Colors.transparent,
      shadowColor: theme.shadowColor,
      elevation: 0,
      textStyle: theme.textTheme.labelLarge,
      padding: _scaledPadding(context),
      minimumSize: const Size(64, 36),
      fixedSize: const Size.fromHeight(40),
      maximumSize: Size.infinite,
      side: BorderSide.none,
      shape: defaultShape,
      enabledMouseCursor: SystemMouseCursors.click,
      disabledMouseCursor: SystemMouseCursors.basic,
      visualDensity: theme.visualDensity,
      tapTargetSize: theme.materialTapTargetSize,
      animationDuration: kThemeChangeDuration,
      enableFeedback: true,
      alignment: Alignment.center,
      splashFactory: InkRipple.splashFactory,
    );
  }

  @override
  ButtonStyle? themeStyleOf(BuildContext context) {
    return OutlinedButtonTheme.of(context).style?.copyWith(
      side: WidgetStateProperty.resolveWith<BorderSide?>((state){
        if(state.contains(WidgetState.disabled)){
          return BorderSide.none;
        }
        return BorderSide.none;
      }),

      shape: WidgetStateProperty.resolveWith<OutlinedBorder?>((state){
        return defaultShape;
      }),

      overlayColor: WidgetStateProperty.resolveWith<Color?>((state){
        return AppColors.red[200];
      }),

      backgroundColor: WidgetStateProperty.resolveWith<Color?>((state){
        if(state.contains(WidgetState.disabled)){
          return AppColors.gray[200];
        }
        return AppColors.red[100];
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>((state){
        if(state.contains(WidgetState.disabled)){
          return AppColors.gray[500];
        }
        return AppColors.red[500];
      }),
    );
  }
}



EdgeInsetsGeometry _scaledPadding(BuildContext context) {
  final ThemeData theme = Theme.of(context);
  final double padding1x = theme.useMaterial3 ? 24.0 : 16.0;
  final double defaultFontSize = theme.textTheme.labelLarge?.fontSize ?? 14.0;
  final double effectiveTextScale = MediaQuery.textScalerOf(context).scale(defaultFontSize) / 14.0;

  return ButtonStyleButton.scaledPadding(
    EdgeInsets.symmetric(horizontal: padding1x),
    EdgeInsets.symmetric(horizontal: padding1x / 2),
    EdgeInsets.symmetric(horizontal: padding1x / 2 / 2),
    effectiveTextScale,
  );
}

@immutable
class _CircleButtonDefaultColor extends WidgetStateProperty<Color?> with Diagnosticable {
  _CircleButtonDefaultColor(this.color, this.disabled);

  final Color? color;
  final Color? disabled;

  @override
  Color? resolve(Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return disabled;
    }
    return color;
  }
}

@immutable
class _CircleButtonDefaultOverlay extends WidgetStateProperty<Color?> with Diagnosticable {
  _CircleButtonDefaultOverlay(this.overlay);

  final Color overlay;

  @override
  Color? resolve(Set<WidgetState> states) {
    if (states.contains(WidgetState.pressed)) {
      return overlay.withValues(alpha: 0.1);
    }
    if (states.contains(WidgetState.hovered)) {
      return overlay.withValues(alpha: 0.08);
    }
    if (states.contains(WidgetState.focused)) {
      return overlay.withValues(alpha: 0.1);
    }
    return null;
  }
}

@immutable
class _CircleButtonDefaultElevation extends WidgetStateProperty<double> with Diagnosticable {
  _CircleButtonDefaultElevation(this.elevation);

  final double elevation;

  @override
  double resolve(Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return 0;
    }
    if (states.contains(WidgetState.pressed)) {
      return elevation + 6;
    }
    if (states.contains(WidgetState.hovered)) {
      return elevation + 2;
    }
    if (states.contains(WidgetState.focused)) {
      return elevation + 2;
    }
    return elevation;
  }
}

@immutable
class _CircleButtonDefaultMouseCursor extends WidgetStateProperty<MouseCursor?> with Diagnosticable {
  _CircleButtonDefaultMouseCursor(this.enabledCursor, this.disabledCursor);

  final MouseCursor? enabledCursor;
  final MouseCursor? disabledCursor;

  @override
  MouseCursor? resolve(Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return disabledCursor;
    }
    return enabledCursor;
  }
}

