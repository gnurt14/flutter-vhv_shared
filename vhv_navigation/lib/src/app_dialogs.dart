import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vhv_navigation/vhv_navigation.dart';
import 'package:vhv_shared/vhv_shared.dart';

class AppDialogs {
  static const _defaultPadding = EdgeInsets.all(16);

  static double _widthDialog(DialogSize dialogSize) {
    switch (dialogSize) {
      case DialogSize.small:
        return 500 - 32;
      case DialogSize.medium:
        return 800.0;
      case DialogSize.large:
        return 1140.0;
      default:
        return globalContext.width - 32;
    }
  }

  static Widget _actionsBuilder(Axis direction, List<Widget>? actions, EdgeInsets padding) {
    if (actions == null || actions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(
        left: padding.left - 8.0,
        right: padding.right - 8.0,
        bottom: padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: _defaultPadding.top),
          if (direction == Axis.vertical)
            Column(
              children: actions
                  .map((e) => Padding(
                padding: EdgeInsets.only(top: _defaultPadding.top, left: 8.0, right: 8.0),
                child: SizedBox(width: double.infinity, height: 48, child: e),
              ))
                  .toList(),
            ),
          if (direction == Axis.horizontal)
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: actions
                  .map((e) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SizedBox(
                    height: 48,
                    child: e,
                  ),
                ),
              ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  static Future showActionDialog({
    required BuildContext context,
    Widget? image,
    bool showFullImage = false,
    String? message,
    Widget? content,
    Widget? label,
    String? labelText,
    TextStyle? titleTextStyle,
    TextStyle? contentTextStyle,
    List<Widget>? actions,
    bool showCloseButton = true,
    EdgeInsets? padding,
    IconAlignment? closeButtonAlign = IconAlignment.end,
    double lineSpace = 20.0,
    ShapeBorder? shape,
    Axis actionsDirection = Axis.horizontal,
    bool barrierDismissible = true,
    DialogSize dialogSize = DialogSize.auto,
    Widget? child,
    PopInvokedWithResultCallback? onPopInvokedWithResult,
    bool canPop = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) {
        if(child != null){
          return child;
        }
        return PopScope(
          canPop: canPop,
          onPopInvokedWithResult: onPopInvokedWithResult,
          child: Dialog(
            insetPadding: Theme.of(context).dialogTheme.insetPadding ?? EdgeInsets.all(20),
            shape: shape ?? Theme.of(context).dialogTheme.shape ?? RoundedRectangleBorder(
                borderRadius: baseBorderRadius
            ),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: _widthDialog(dialogSize),
              // padding: EdgeInsets.all(paddingBase),
              child: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showFullImage && image != null) image,
                      Padding(
                        padding: (padding ?? _defaultPadding).copyWith(bottom: (actions?.isNotEmpty == true) ? 0 : null),
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (image != null && !showFullImage) ...[
                                image,
                                SizedBox(height: lineSpace),
                              ],
                              if (labelText != null && label == null)
                                Text(
                                  labelText,
                                  style: titleTextStyle
                                      ?? Theme.of(context).dialogTheme.titleTextStyle,
                                  textAlign: TextAlign.left,
                                ).marginOnly(
                                  right: showCloseButton ? 40 : 0
                                ),
                              if (label != null) label.marginOnly(
                                  right: showCloseButton ? 40 : 0
                              ),
                              if ((labelText != null || label != null) && (message != null || content != null))
                                SizedBox(height: max(lineSpace - 5, 7)),
                              if (message != null && content == null)
                                SizedBox(
                                  width: double.infinity,
                                  child: HtmlWidget(
                                    message,
                                    textStyle: contentTextStyle ?? Theme.of(context).dialogTheme.contentTextStyle,
                                  ),
                                ),
                              if (content != null) SizedBox(width: context.width, child: content,),
                            ],
                          ),
                        ),
                      ),
                      if (actions != null)_actionsBuilder(actionsDirection, actions, padding ?? _defaultPadding),
                    ],
                  ),
                  if (showCloseButton)
                    Positioned(
                      top: 4,
                      left: closeButtonAlign == IconAlignment.start ? 2 : null,
                      right: closeButtonAlign == IconAlignment.end ? 2 : null,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => appNavigator.pop(),
                      ),
                    ),
                ],
              ),
            ).tapRemoveFocus(context),
          ),
        );
      },
    );
  }
  static Future<dynamic> delete({
    required BuildContext context,
    String? title,
    String? note,
    String? message,
    String? textConfirm,
    String? textCancel,
    bool barrierDismissible = true,
    Widget? child,
    PopInvokedWithResultCallback? onPopInvokedWithResult,
    bool canPop = true,
    DialogSize? dialogSize,
    String? service,
    Map? params,
    Function()? onConfirm,
    Function()? onCancel,
    Function(Map res)? onSuccess,
    Function(Map res)? onFail,
    String? messageSuccess,
    String? messageFail,
  }) {
    assert((onConfirm != null) != (service != null), 'onConfirm/service khác null và không cùng có giá trị');
    if(!context.mounted){
      return Future.value(null);
    }
    FocusScope.of(context).requestFocus(FocusNode());
    return showActionDialog(
      context: context,
      content: HtmlWidget(
        '<div style="margin-bottom: 10px;">$message</div>'
            '<div><b>Lưu ý:</b> ${note ?? 'Xóa xong không thể khôi phục lại được'}</div>',
        textStyle: Theme.of(context).dialogTheme.contentTextStyle,
      ),
      labelText: title ?? 'Xác nhận'.lang(),
      dialogSize: dialogSize ?? DialogSize.auto,
      barrierDismissible: barrierDismissible,
      child: child,
      canPop: canPop,
      onPopInvokedWithResult: onPopInvokedWithResult,
      actions: [
        BaseButton.outlined(
          onPressed: onCancel ?? (){
            appNavigator.pop();
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: getProperties(AppColors.gray300, AppColors.gray500)!),
            foregroundColor: getProperties(AppColors.gray900, AppColors.gray100)
          ),
          child: Text(textCancel ?? lang('Hủy')),
        ),
        BaseButton(
          onPressed: onConfirm ?? ()async{
            AppLoadingManager.instance.showLoading();
            final res = await VHVShared().callAPI(service ?? '', params: params);
            AppLoadingManager.instance.disableLoading();
            if (res is Map) {
              if (res['status'] == 'SUCCESS') {
                onSuccess?.call(res);
                showMessage(messageSuccess ?? res['message'], type: 'SUCCESS');
              } else {
                onFail?.call(res);
                showMessage(messageFail ?? res['message'] ?? 'Có lỗi xảy ra!'.lang(), type: 'ERROR');
              }
            }else{
              showMessage(messageFail ?? 'Có lỗi xảy ra!'.lang(), type: 'ERROR');
            }

          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffB9000E),
          ),
          child: Text(textConfirm ?? lang('Xóa')),
        ),
      ],
    );
  }
  static Future<dynamic> showConfirmDialog({
    required BuildContext context,
    String? title,
    String? message,
    Widget? content,
    Widget? icon,
    Function()? onConfirm,
    VoidCallback? onCancel,
    String? textConfirm,
    String? textCancel,
    String? note,
    bool showCloseButton = true,
    List<Widget>? actions,
    TextStyle? titleTextStyle,
    TextStyle? contentTextStyle,
    bool barrierDismissible = true,
    Widget? child,
    PopInvokedWithResultCallback? onPopInvokedWithResult,
    bool canPop = true,
    DialogSize? dialogSize,
  }) {
    bool submitting = false;
    return showActionDialog(
      context: context,
      message: message,
      content: content ?? (note != null ? HtmlWidget(
        '<div style="margin-bottom: 10px;">$message</div>'
            '<div><b>Lưu ý:</b> $note</div>',
        textStyle: Theme.of(context).dialogTheme.contentTextStyle,
      ) : null),
      labelText: title,
      image: icon,
      dialogSize: dialogSize ?? DialogSize.auto,
      showCloseButton: showCloseButton,
      titleTextStyle: titleTextStyle,
      contentTextStyle: contentTextStyle,
      barrierDismissible: barrierDismissible,
      child: child,
      canPop: canPop,
      onPopInvokedWithResult: onPopInvokedWithResult,
      actions: [
        if(onCancel != null)BaseButton.outlined(
          onPressed: onCancel,
          child: Text(textCancel ?? lang('Hủy')),
        ),
        if(onConfirm != null)BaseButton(
          onPressed: ()async{
            if(!submitting) {
              submitting = true;
              await onConfirm?.call();
              submitting = false;
            }
          },
          child: Text(textConfirm ?? lang('Đồng ý')),
        ),
        if(actions != null)...actions
      ],
    );
  }

  static Future showFullPageDialog({
    required BuildContext context,
    required Widget child,
    Widget? actionButton,
    bool showCloseButton = true,
  }) {
    return showDialog(
      context: context,
      useSafeArea: false,
      builder: (context) => child,
    );
  }
}
