import 'package:bottom_sheet/bottom_sheet.dart' as bottom_sheet;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:vhv_navigation/vhv_navigation.dart';
import 'package:vhv_shared/vhv_shared.dart';

export 'package:bottom_sheet/bottom_sheet.dart' show FlexibleDraggableScrollableWidgetBuilder;

class AppBottomSheets {
  AppBottomSheets._();
  static AppBottomSheets? _instance;

  factory AppBottomSheets(){
    _instance ??= AppBottomSheets._();
    return _instance!;
  }
  bool _showTop(BuildContext context) => context.bottomSheetType == BottomSheetType.type1;

  Future showFlexibleBottomSheet({
    final Color? backgroundColor,
    final EdgeInsets? padding,
    final BorderRadiusGeometry? borderRadius,
    bool isDismissible = true,
    bool ignoreSafeArea = false,
    bool isScrollControlled = true,
    bool enableDrag = true,
    bool canPop = true,
    double initHeight = 0.5,
    PopInvokedWithResultCallback? onPopInvokedWithResult,
    BuildContext? context,
    bool isSafeArea = false,
    String? title,
    required bottom_sheet.FlexibleDraggableScrollableWidgetBuilder builder,
  }){
    assert(initHeight > 0.1);
    return bottom_sheet.showFlexibleBottomSheet<void>(
      minHeight: 0,
      initHeight: initHeight > 0.9 ? 0.9 : initHeight,
      maxHeight: 0.9,
      context: context ?? globalContext,
      isSafeArea: isSafeArea,
      bottomSheetColor: Colors.transparent,
      bottomSheetBorderRadius: BorderRadius.zero,
      builder: (context, controller, value){
        return _bottomSheetBackground(
          context,
          useScroll: false,
          title: title,
          child: builder(context, controller, value).marginOnly(
            top: !_showTop(context) ? 7 : 0
          ),
        );
      },
      anchors: [0, 0.5, 0.9],
      useRootScaffold: false,
    );
  }
  Future show({
    final Key? key,
    final Widget? child,
    final Widget? bottom,
    final dynamic title,
    final Widget? actionRight,
    final Widget? actionLeft,
    final Color? backgroundColor,
    final EdgeInsets? padding,
    final BorderRadiusGeometry? borderRadius,
    bool isDismissible = true,
    bool ignoreSafeArea = false,
    bool isScrollControlled = true,
    bool enableDrag = true,
    bool canPop = true,
    PopInvokedWithResultCallback? onPopInvokedWithResult,
    BuildContext? context,
    bool isSafeArea = false,
    bool useRootNavigator = true
  }){
    return showModalBottomSheet(
      context: context ?? globalContext,
      useSafeArea: !ignoreSafeArea,
      backgroundColor: Colors.transparent,
      useRootNavigator: useRootNavigator,
      builder: (context){
        return PopScope(
          key: key,
          canPop: canPop,
          onPopInvokedWithResult: onPopInvokedWithResult,
          child: _bottomSheetBackground(context,
            title: title,
            bottom: bottom,
            actionLeft: actionLeft,
            actionRight: actionRight,
            child: child ?? const SizedBox.shrink(),
            padding: padding ?? EdgeInsets.all(paddingBase),
          ),
        );
     },
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag);
  }
  Future showCustom({
    final Widget? child,
    final Widget? bottom,
    final dynamic title,
    final Widget? actionRight,
    final Widget? actionLeft,
    final BottomSheetType? type,
    final Color? backgroundColor,
    final EdgeInsets? padding,
    final BorderRadiusGeometry? borderRadius,
    bool isDismissible = true,
    bool ignoreSafeArea = false,
    bool isScrollControlled = true,
    bool enableDrag = true,
    bool canPop = true,
    PopInvokedWithResultCallback? onPopInvokedWithResult,
    BuildContext? context,
    bool isSafeArea = false
  }){
    return showModalBottomSheet(
      context: context ?? globalContext,
      useSafeArea: !ignoreSafeArea,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context){
        return PopScope(
          canPop: canPop,
          onPopInvokedWithResult: onPopInvokedWithResult,
          child: child ?? const SizedBox.shrink(),
        );
      },
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag
    );
  }
  Future showFixedHeightSheet({
    required BuildContext context,
    Widget? title,
    Widget? leftAction,
    Widget? rightAction,
    required Widget child,
    Widget? bottomAction,
    EdgeInsets titlePadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    EdgeInsets contentPadding = const EdgeInsets.all(16),
    EdgeInsets bottomActionPadding = const EdgeInsets.all(16),
    double? maxHeightFactor,
    double? minHeightFactor,
  }) {
    assert(maxHeightFactor == null || maxHeightFactor < 1);
    return _showBottomSheet(
      context: context,
      title: title,
      leftAction: leftAction,
      rightAction: rightAction,
      child: child,
      bottomAction: bottomAction,
      minHeightFactor: minHeightFactor ?? 0.5,
      maxHeightFactor: maxHeightFactor ?? 0.9,
      titlePadding: titlePadding,
      contentPadding: contentPadding,
      bottomActionPadding: bottomActionPadding,
    );
  }

  Future showExpandableHeightSheet({
    required BuildContext context,
    Widget? title,
    Widget? leftAction,
    Widget? rightAction,
    required Widget child,
    Widget? bottomAction,
    EdgeInsets titlePadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    EdgeInsets contentPadding = const EdgeInsets.all(16),
    EdgeInsets bottomActionPadding = const EdgeInsets.all(16),
  }) {
    return _showBottomSheet(
      context: context,
      title: title,
      leftAction: leftAction,
      rightAction: rightAction,
      child: child,
      bottomAction: bottomAction,
      minHeightFactor: null, // Không có minHeight
      maxHeightFactor: 0.9,
      titlePadding: titlePadding,
      contentPadding: contentPadding,
      bottomActionPadding: bottomActionPadding,
    );
  }

  Future _showBottomSheet({
    required BuildContext context,
    Widget? title,
    Widget? leftAction,
    Widget? rightAction,
    required Widget child,
    Widget? bottomAction,
    double? minHeightFactor,
    double maxHeightFactor = 0.9,
    EdgeInsets titlePadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    EdgeInsets contentPadding = const EdgeInsets.all(16),
    EdgeInsets bottomActionPadding = const EdgeInsets.all(16),
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;
        final viewInsets = MediaQuery.of(context).viewInsets.bottom;

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: viewInsets),
            child: Container(
              constraints: BoxConstraints(
                minHeight: minHeightFactor != null ? screenHeight * minHeightFactor : 0,
                maxHeight: screenHeight * maxHeightFactor - viewInsets,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null) ...[
                    Padding(
                      padding: titlePadding,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              leftAction ?? const SizedBox(width: 48),
                              rightAction ?? const SizedBox(width: 48),
                            ],
                          ),
                          Center(child: title),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                  ],
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: contentPadding,
                        child: child,
                      ),
                    ),
                  ),
                  if (bottomAction != null) ...[
                    const Divider(height: 1),
                    Padding(
                      padding: bottomActionPadding,
                      child: bottomAction,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _bottomSheetBackground(BuildContext context, {
    Color? backgroundColor,
    BorderRadius? borderRadius,
    dynamic title,
    Widget? actionLeft,
    Widget? actionRight,
    Widget? child,
    EdgeInsets? padding,
    Widget? bottom,
    bool useScroll = true
  }){
    return ClipRRect(
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0)),
      child: Container(
        width: double.infinity,
        padding: useScroll ? EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom
        ) : null,
        decoration: BoxDecoration(
          borderRadius: borderRadius??const BorderRadius.only(
            topLeft: Radius.circular(15.0),
            topRight: Radius.circular(15.0),
          ),
          color: backgroundColor??Theme.of(context).cardColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (context.bottomSheetType == BottomSheetType.type2)InkWell(
              child: Container(
                height: 6,
                width: 40,
                margin: const EdgeInsets.only(bottom: 7, top: 7),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
              ),
              onTap: () {
                try{
                  appNavigator.pop();
                }catch(e){
                  Navigator.of(context).pop();
                }
              },
            ),
            if(title != null)Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      width: 1.0,
                      color: const Color(0xffF1F1F1).withValues(alpha: 0.5)),
                ),
              ),
              child: Row(
                children: <Widget>[
                  if(actionLeft != null)actionLeft,
                  if(actionLeft == null && context.bottomSheetType == BottomSheetType.type2)SizedBox(
                    width: kMinInteractiveDimension,
                    child: IconButton(
                        onPressed: (){
                          try{
                            appNavigator.pop();
                          }catch(e){
                            Navigator.of(context).pop();
                          }
                        },
                        icon: Icon(ViIcons.x_small)
                    ),
                  ),
                  Expanded(child: Padding(
                    padding: basePadding,
                    child: Builder(
                      builder: (_){
                        return Align(
                          alignment: _getAlignment(
                            actionLeft: actionLeft,
                            actionRight: actionRight,
                          ),
                          child: title is Widget ? title : Text(
                            '$title',
                            style: Theme.of(context).dialogTheme.titleTextStyle ?? const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
                  )),
                  if(actionLeft == null && actionRight == null
                      && context.bottomSheetType == BottomSheetType.type2)SizedBox(
                    width: kMinInteractiveDimension,
                  ),
                  if(actionRight != null)LayoutBuilder(
                      builder: (context, con){
                        return actionRight;
                      }
                  ),
                ],
              ),
            ),
            if(child != null)Flexible(
              child: useScroll ? OverflowBox(
                fit: OverflowBoxFit.deferToChild,
                child: SingleChildScrollView(
                  padding: padding ?? EdgeInsets.zero, child: child,
                ),
              ) : child,
            ),
            if(bottom != null)bottom
          ],
        ),
      ),
    );
  }
  Alignment _getAlignment({Widget? actionLeft, Widget? actionRight}) {
    if(actionLeft != null && actionRight != null){
      return Alignment.center;
    }else if(actionLeft != null){
      return Alignment.centerRight;
    }else if(actionRight != null){
      return Alignment.centerLeft;
    }else{
      return Alignment.center;
    }
  }
}