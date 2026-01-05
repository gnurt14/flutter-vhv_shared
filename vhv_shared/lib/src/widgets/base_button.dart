import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:vhv_shared/src/theme_extensions/base_button_theme.dart';
@protected
enum BaseButtonType {
  primary,
  outlined,
  dashed,
  text,
  // secondary,
  // destruction,
}

class BaseButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final ValueChanged<bool>? onHover;
  final ValueChanged<bool>? onFocusChange;
  final ButtonStyle? style;
  final FocusNode? focusNode;
  final bool autofocus;
  final Clip clipBehavior;
  final Widget? child;
  final BaseButtonType type;
  final DashedButtonStyle? dashedStyle;

  const BaseButton({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
    required this.child,
  }) : type = BaseButtonType.primary, dashedStyle = null;

  @override
  Widget build(BuildContext context) {
    final dashedTheme = Theme.of(context).extension<DashedButtonThemeData>();

    switch (type) {
      case BaseButtonType.text:
        return TextButton(
          onPressed: onPressed,
          onLongPress: onLongPress,
          onHover: onHover,
          style: style,
          focusNode: focusNode,
          autofocus: autofocus,
          clipBehavior: clipBehavior,
          onFocusChange: onFocusChange,
          child: child ?? const SizedBox.shrink(),
        );
      case BaseButtonType.outlined:
      // case BaseButtonType.dashed:
        return OutlinedButton(
          onPressed: onPressed,
          onLongPress: onLongPress,
          onHover: onHover,
          style: style,
          focusNode: focusNode,
          autofocus: autofocus,
          clipBehavior: clipBehavior,
          onFocusChange: onFocusChange,
          child: child ?? const SizedBox.shrink(),
        );
      case BaseButtonType.dashed:
        return OutlinedButton(
          onPressed: onPressed,
          onLongPress: onLongPress,
          onHover: onHover,
          style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  side: BorderSide.none,
                  borderRadius: BorderRadius.circular((dashedTheme?.style.radius ?? const Radius.circular(12)).x)
              ),
              side: BorderSide.none,
              disabledForegroundColor: Theme.of(context).disabledColor,
              backgroundBuilder: (_, state, child){
                return DottedBorder(
                  options: RoundedRectDottedBorderOptions(
                    // borderType: (dashedStyle ?? dashedTheme?.style)?.borderType ?? BorderType.RRect,
                    radius:  (dashedStyle ?? dashedTheme?.style)?.radius ?? const Radius.circular(12),
                    dashPattern: (dashedStyle ?? dashedTheme?.style)?.dashPattern ?? const [3, 3],
                    borderPadding: (dashedStyle ?? dashedTheme?.style)?.borderPadding ?? const EdgeInsets.all(1),
                    color: state.contains(WidgetState.disabled)
                        ? (dashedStyle ?? dashedTheme?.style)?.disabledColor ?? Theme.of(context).disabledColor
                        : (dashedStyle ?? dashedTheme?.style)?.color ?? Theme.of(context).primaryColor,
                    padding: (dashedStyle ?? dashedTheme?.style)?.padding ?? const EdgeInsets.all(12),
                  ),

                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(((dashedStyle ?? dashedTheme?.style)?.radius ?? const Radius.circular(12)).x),
                      child: Center(
                        // color: Colors.red,
                        child: child!,
                      ),
                    )
                );
              }
          ),
          focusNode: focusNode,
          autofocus: autofocus,
          clipBehavior: clipBehavior,
          onFocusChange: onFocusChange,
          child: child ?? const SizedBox.shrink()
        );

      default:
        return ElevatedButton(
          onPressed: onPressed,
          onLongPress: onLongPress,
          onHover: onHover,
          style: style,
          focusNode: focusNode,
          autofocus: autofocus,
          clipBehavior: clipBehavior,
          onFocusChange: onFocusChange,

          child: child ?? const SizedBox.shrink(),
        );
    }
  }

  const BaseButton.outlined({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.onHover,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
    this.child,
    this.onFocusChange,
  }) : type = BaseButtonType.outlined, dashedStyle = null;

  BaseButton.icon({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.onHover,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
    this.onFocusChange,
    required Widget label,
    Widget? icon,
    IconAlignment iconAlignment = IconAlignment.start
  }) : type = BaseButtonType.primary,
        child = icon != null ? _BaseButtonWithIconChild(
          label: label,
          icon: icon,
          buttonStyle: style,
          iconAlignment: iconAlignment,
        ) : label, dashedStyle = null;


  BaseButton.outlinedIcon({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.onHover,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
    this.onFocusChange,
    required Widget label,
    Widget? icon,
    IconAlignment iconAlignment = IconAlignment.start
  }) : type = BaseButtonType.outlined,
        child = icon != null ? _BaseButtonWithIconChild(
          label: label,
          icon: icon,
          buttonStyle: style,
          iconAlignment: iconAlignment,
        ) : label, dashedStyle = null;

  const BaseButton.dashed({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.onHover,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
    this.child,
    this.onFocusChange,
    this.dashedStyle
  }) : type = BaseButtonType.dashed;

  BaseButton.dashedIcon({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.onHover,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
    this.dashedStyle,
    this.onFocusChange,required Widget label,
    Widget? icon,
    IconAlignment iconAlignment = IconAlignment.start
  }) : type = BaseButtonType.dashed,
        child = icon != null ? _BaseButtonWithIconChild(
          label: label,
          icon: icon,
          buttonStyle: style,
          iconAlignment: iconAlignment,
        ) : label;
}
class _BaseButtonWithIconChild extends StatelessWidget {
  const _BaseButtonWithIconChild({
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