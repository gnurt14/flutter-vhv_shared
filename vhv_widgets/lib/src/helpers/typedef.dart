part of '../helper.dart';

typedef FormCaptchaCustom = Widget Function({
  Function(String)? onChanged,
  Function()? onTap,
  String? errorText,
  FocusNode? focusNode,
  Widget? prefixIcon,
  VoidCallback? onEditingComplete,
  bool reloadInInit,
  bool autofocus,
  String? value,
  Function(VoidCallback)? buildReloadCaptcha
});
typedef AsyncCallbackFunc = Future<void> Function();
typedef ValueChangedAsync = Future Function(Map value);
typedef OnWillPop = Future<bool> Function();
typedef BottomSheetFunction = Future Function({
  Widget? child,
  Widget? bottom,
  dynamic title,
  Widget? actionRight,
  Widget? actionLeft,
  BottomSheetType? type,
  Color? backgroundColor,
  EdgeInsets? padding,
  BorderRadiusGeometry? borderRadius,
  bool isDismissible,
  bool ignoreSafeArea,
  bool isScrollControlled,
  bool persistent,
  bool enableDrag,
  OnWillPop? onWillPop,
});
typedef ShowDialogFunction = Future Function({
  String? title,
  TextStyle? titleStyle,
  Widget? content,
  String? middleText,
  Widget? cancel,
  List<Widget>? actions,
  VoidCallback? onCancel,
  VoidCallback? onCustom,
  VoidCallback? onConfirm,
  Color? confirmTextColor,
  Color? confirmColor,
  Color? backgroundColor,
  String? textConfirm,
  String? textCancel,
  String? textCustom,
  bool barrierDismissible,
  double radius,
  double elevation,
  PopInvokedWithResultCallback? onPopInvokedWithResult,
  bool canPop,
  EdgeInsets? insetPadding,
  EdgeInsets? contentPadding,
  bool showCloseButton,
  DialogSize dialogSize
});
typedef ShowFullDialog = Future Function({
  bool barrierDismissible,
  required Widget child,
  OnWillPop? onWillPop,
});
typedef ShowSnackBar = Function({
  required String? message,
  Duration? duration
});
typedef AppBarDefault = AppBar Function({
  Widget? leading,
  bool automaticallyImplyLeading,
  Widget? title,
  List<Widget>? actions,
  Widget? flexibleSpace,
  PreferredSizeWidget? bottom,
  double? elevation,
  double? scrolledUnderElevation,
  ScrollNotificationPredicate notificationPredicate,
  Color? shadowColor,
  Color? surfaceTintColor,
  ShapeBorder? shape,
  Color? backgroundColor,
  Color? foregroundColor,
  bool? centerTitle,
  double? titleSpacing,
  double? leadingWidth,
});