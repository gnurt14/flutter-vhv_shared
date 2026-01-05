// import 'dart:ui';
//
// import 'package:flutter/material.dart';
// import 'package:vhv_shared/src/theme_extensions/base_button_theme.dart';
// @protected
// enum BaseButtonType {
//   primary,
//   outlined,
//   // dashed,
//   text,
//   // secondary,
//   // destruction,
// }
//
// class BaseButtonNew extends StatelessWidget {
//   final VoidCallback? onPressed;
//   final VoidCallback? onLongPress;
//   final Function(bool)? onHover;
//   final ButtonStyle? style;
//   final FocusNode? focusNode;
//   final bool autofocus;
//   final Clip clipBehavior;
//   final Widget? child;
//   final BaseButtonType type;
//
//   const BaseButtonNew({
//     super.key,
//     required this.onPressed,
//     this.onLongPress,
//     this.onHover,
//     this.style,
//     this.focusNode,
//     this.autofocus = false,
//     this.clipBehavior = Clip.none,
//     required this.child,
//   }) : type = BaseButtonType.primary;
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context).extension<BaseButtonTheme>();
//
//     final ButtonStyle? themedStyle;
//     switch (type) {
//       case BaseButtonType.primary:
//         themedStyle = theme?.primary?.style;
//         break;
//       case BaseButtonType.outlined:
//         themedStyle = theme?.outlined?.style;
//         break;
//       case BaseButtonType.text:
//         themedStyle = theme?.text?.style;
//         break;
//     }
//
//     final resolvedStyle = themedStyle?.merge(style) ?? style;
//
//     switch (type) {
//       case BaseButtonType.text:
//         return TextButton(
//           onPressed: onPressed,
//           onLongPress: onLongPress,
//           onHover: onHover,
//           style: resolvedStyle,
//           focusNode: focusNode,
//           autofocus: autofocus,
//           clipBehavior: clipBehavior,
//           child: child ?? const SizedBox.shrink(),
//         );
//       case BaseButtonType.outlined:
//       // case BaseButtonType.dashed:
//         return OutlinedButton(
//           onPressed: onPressed,
//           onLongPress: onLongPress,
//           onHover: onHover,
//           style: resolvedStyle,
//           focusNode: focusNode,
//           autofocus: autofocus,
//           clipBehavior: clipBehavior,
//           child: child ?? const SizedBox.shrink(),
//         );
//       default:
//         return ElevatedButton(
//           onPressed: onPressed,
//           onLongPress: onLongPress,
//           onHover: onHover,
//           style: resolvedStyle,
//           focusNode: focusNode,
//           autofocus: autofocus,
//           clipBehavior: clipBehavior,
//           child: child ?? const SizedBox.shrink(),
//         );
//     }
//   }
//
//   static ButtonStyle styleFrom({
//     Color? backgroundColor,
//     Color? foregroundColor,
//     Color? overlayColor,
//     Color? shadowColor,
//     double? elevation,
//     TextStyle? textStyle,
//     EdgeInsetsGeometry? padding,
//     Size? minimumSize,
//     BorderSide? side,
//     OutlinedBorder? shape,
//     MouseCursor? enabledMouseCursor,
//     MouseCursor? disabledMouseCursor,
//     VisualDensity? visualDensity,
//     MaterialTapTargetSize? tapTargetSize,
//     Duration? animationDuration,
//     AlignmentGeometry? alignment,
//     InteractiveInkFeatureFactory? splashFactory,
//   }) {
//     return ButtonStyle(
//       backgroundColor: backgroundColor != null
//           ? WidgetStateProperty.all(backgroundColor)
//           : null,
//       foregroundColor: foregroundColor != null
//           ? WidgetStateProperty.all(foregroundColor)
//           : null,
//       overlayColor: overlayColor != null
//           ? WidgetStateProperty.all(overlayColor)
//           : null,
//       shadowColor: shadowColor != null
//           ? WidgetStateProperty.all(shadowColor)
//           : null,
//       elevation: elevation != null
//           ? WidgetStateProperty.all(elevation)
//           : null,
//       textStyle: textStyle != null
//           ? WidgetStateProperty.all(textStyle)
//           : null,
//       padding: padding != null
//           ? WidgetStateProperty.all(padding)
//           : null,
//       minimumSize: minimumSize != null
//           ? WidgetStateProperty.all(minimumSize)
//           : null,
//       side: side != null
//           ? WidgetStateProperty.all(side)
//           : null,
//       shape: shape != null
//           ? WidgetStateProperty.all(shape)
//           : null,
//       mouseCursor: enabledMouseCursor != null
//           ? WidgetStateProperty.resolveWith<MouseCursor>(
//             (states) => states.contains(WidgetState.disabled)
//             ? (disabledMouseCursor ?? SystemMouseCursors.basic)
//             : enabledMouseCursor,
//       )
//           : null,
//       visualDensity: visualDensity,
//       tapTargetSize: tapTargetSize,
//       animationDuration: animationDuration,
//       alignment: alignment,
//       splashFactory: splashFactory,
//     );
//   }
//
//   const BaseButtonNew.outline({
//     super.key,
//     required this.onPressed,
//     this.onLongPress,
//     this.onHover,
//     this.style,
//     this.focusNode,
//     this.autofocus = false,
//     this.clipBehavior = Clip.none,
//     this.child,
//   }) : type = BaseButtonType.outlined;
//
//   BaseButtonNew.icon({
//     super.key,
//     required this.onPressed,
//     this.onLongPress,
//     this.onHover,
//     this.style,
//     this.focusNode,
//     this.autofocus = false,
//     this.clipBehavior = Clip.none,
//     required Widget label,
//     Widget? icon,
//     IconAlignment iconAlignment = IconAlignment.start
//   }) : type = BaseButtonType.primary,
//         child = icon != null ? _BaseButtonWithIconChild(
//           label: label,
//           icon: icon,
//           buttonStyle: style,
//           iconAlignment: iconAlignment,
//         ) : label;
//
//
//   BaseButtonNew.outlinedIcon({
//     super.key,
//     required this.onPressed,
//     this.onLongPress,
//     this.onHover,
//     this.style,
//     this.focusNode,
//     this.autofocus = false,
//     this.clipBehavior = Clip.none,
//     required Widget label,
//     Widget? icon,
//     IconAlignment iconAlignment = IconAlignment.start
//   }) : type = BaseButtonType.outlined,
//         child = icon != null ? _BaseButtonWithIconChild(
//           label: label,
//           icon: icon,
//           buttonStyle: style,
//           iconAlignment: iconAlignment,
//         ) : label;
// }
// class _BaseButtonWithIconChild extends StatelessWidget {
//   const _BaseButtonWithIconChild({
//     required this.label,
//     required this.icon,
//     required this.buttonStyle,
//     required this.iconAlignment,
//   });
//
//   final Widget label;
//   final Widget icon;
//   final ButtonStyle? buttonStyle;
//   final IconAlignment iconAlignment;
//
//   @override
//   Widget build(BuildContext context) {
//     final double defaultFontSize = buttonStyle?.textStyle?.resolve(const <WidgetState>{})?.fontSize ?? 14.0;
//     final double scale = clampDouble(MediaQuery.textScalerOf(context).scale(defaultFontSize) / 14.0, 1.0, 2.0) - 1.0;
//     final double gap = lerpDouble(8, 4, scale)!;
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: iconAlignment == IconAlignment.start
//           ? <Widget>[icon, SizedBox(width: gap), Flexible(child: label)]
//           : <Widget>[Flexible(child: label), SizedBox(width: gap), icon],
//     );
//   }
// }