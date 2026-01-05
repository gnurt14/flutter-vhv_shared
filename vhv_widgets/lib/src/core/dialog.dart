import 'package:flutter/material.dart';
import 'package:vhv_widgets/vhv_widgets.dart';


class BaseDialog<T> extends StatelessWidget {
  const BaseDialog({
    super.key,
    this.canPop = true,
    this.onPopInvokedWithResult,
    this.backgroundColor,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.insetAnimationDuration = const Duration(milliseconds: 100),
    this.insetAnimationCurve = Curves.decelerate,
    this.insetPadding = const EdgeInsets.all(20),
    this.clipBehavior,
    this.alignment,
    required this.child,
    ShapeBorder? shape,
  }) : _shape = shape;

  final bool canPop;
  final void Function(bool, T?)? onPopInvokedWithResult;
  final ShapeBorder? _shape;
  final Widget child;
  final Color? backgroundColor;
  final double? elevation;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  final Duration insetAnimationDuration;
  final Curve insetAnimationCurve;
  final EdgeInsets? insetPadding;
  final Clip? clipBehavior;
  final AlignmentGeometry? alignment;

  ShapeBorder get shape => _shape ?? RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  );

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: onPopInvokedWithResult,
      child: Dialog(
        shape: shape,
        backgroundColor: backgroundColor,
        elevation: elevation,
        shadowColor: shadowColor,
        surfaceTintColor: surfaceTintColor,
        insetAnimationDuration: insetAnimationDuration,
        insetAnimationCurve: insetAnimationCurve,
        insetPadding: insetPadding,
        clipBehavior: clipBehavior,
        alignment: alignment,
        child: child,
      ),
    );
  }
}
class ConfirmBaseDialog extends Dialog{
  const ConfirmBaseDialog({
    super.key,
    super.backgroundColor,
    super.elevation,
    super.shadowColor,
    super.surfaceTintColor,
    super.insetAnimationDuration = const Duration(milliseconds: 100),
    super.insetAnimationCurve = Curves.decelerate,
    super.insetPadding = const EdgeInsets.all(20),
    this.contentPadding = const EdgeInsets.all(20),
    super.clipBehavior,
    super.shape,
    super.alignment,
    this.canPop = true,
    this.onPopInvokedWithResult,
    this.radius = 10.0,
    this.dialogSize = DialogSize.auto,
    this.showCloseButton = false,
    this.title = '',
    this.titleStyle,
    this.middleText,
    this.textConfirm,
    this.textCancel,
    this.confirmTextColor,
    this.confirmColor,
    this.onCancel,
    this.onConfirm,
    this.content,
    this.actions,
  });
  final PopInvokedWithResultCallback? onPopInvokedWithResult;
  final bool canPop;
  final double radius;
  final DialogSize dialogSize;
  final EdgeInsets? contentPadding;
  final bool showCloseButton;
  final String title;
  final TextStyle? titleStyle;
  final String? middleText;
  final String? textConfirm;
  final String? textCancel;
  final Color? confirmTextColor;
  final Color? confirmColor;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final Widget? content;
  final List<Widget>? actions;

  double get width{
    double width = double.infinity;
    if (dialogSize == DialogSize.small) {
      width = 500.0;
    }
    if (dialogSize == DialogSize.medium) {
      width = 800.0;
    }
    if (dialogSize == DialogSize.large) {
      width = 1140.0;
    }
    return width;
  }



  @override
  Widget? get child => PopScope(
    canPop: canPop,
    onPopInvokedWithResult: onPopInvokedWithResult,
    child: Container(
      constraints: BoxConstraints(maxWidth: width),
      width: width,
      child: Builder(builder: (context) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: contentPadding ?? const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (showCloseButton)
                    const SizedBox(
                      height: 20,
                    ),
                  if (!empty(title))
                    Text(title,
                        textAlign: TextAlign.center,
                        style: titleStyle ??
                            Theme.of(globalContext)
                                .textTheme
                                .titleLarge),
                  if (!empty(title)) const SizedBox(height: 20),
                  Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (middleText != null)
                              HTMLViewer(
                                middleText,
                                style: {
                                  '*': Style(textAlign: TextAlign.center)
                                },
                              ),
                            if (content != null) content!,
                            if (!empty(onConfirm) ||
                                !empty(onCancel) ||
                                !empty(actions))
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  children: [
                                    if (!empty(onCancel))
                                      BaseButton.outlined(
                                        onPressed: () {
                                          onCancel!();
                                          appNavigator.pop();
                                        },
                                        style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                                color: Theme.of(context)
                                                    .primaryColor),
                                            foregroundColor: Theme.of(context)
                                                .primaryColor),
                                        child:
                                        Text(lang(textCancel ?? 'Huỷ'.lang())),
                                      ),
                                    if (!empty(onConfirm) && !empty(onCancel))
                                      const SizedBox(width: 20),
                                    if (!empty(onConfirm))
                                      BaseButton(
                                        onPressed: onConfirm,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: confirmColor ??
                                              Theme.of(context).primaryColor,
                                          foregroundColor: confirmTextColor ??
                                              Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                        ),
                                        child: Text(
                                            lang(textConfirm ?? 'Đồng ý'.lang())),
                                      ),
                                    ...actions ?? []
                                  ],
                                ),
                              )
                          ],
                        ),
                      )),
                ],
              ),
            ),
            if (showCloseButton)
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Opacity(
                    opacity: 0.6,
                    child: Icon(ViIcons.x_close),
                  ),
                  onPressed: () async {
                    appNavigator.pop();
                  },
                ),
              )
          ],
        );
      }),
    ),
  );
}

Future<dynamic> showConfirmDialog({
  String? title,
  TextStyle? titleStyle,
  Widget? content,
  String? middleText,
  List<Widget>? actions,
  VoidCallback? onCancel,
  VoidCallback? onConfirm,
  Color? confirmTextColor,
  Color? confirmColor,
  Color? backgroundColor,
  String? textConfirm,
  String? textCancel,
  String? textCustom,
  bool barrierDismissible = true,
  double radius = 10.0,
  double elevation = 10.0,
  PopInvokedWithResultCallback? onPopInvokedWithResult,
  bool canPop = true,
  EdgeInsets? insetPadding,
  EdgeInsets? contentPadding,
  bool showCloseButton = false,
  DialogSize dialogSize = DialogSize.auto,
  BuildContext? context
}){
  return AppDialogs.showConfirmDialog(
    context: context ?? globalContext,
    barrierDismissible: barrierDismissible,
    title: title,
    message: middleText,
    content: content,
    titleTextStyle: titleStyle,
    textConfirm: textConfirm ?? 'Đồng ý'.lang(),
    textCancel: textCancel ?? 'Hủy'.lang(),
    dialogSize: dialogSize,
    showCloseButton: showCloseButton,
    canPop: canPop,
    onPopInvokedWithResult: onPopInvokedWithResult,
    onCancel: onCancel != null ? (){
      onCancel();
      appNavigator.pop();
    } : null,
    onConfirm: onConfirm,
    actions: actions,
  );
}