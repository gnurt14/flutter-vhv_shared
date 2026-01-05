import 'package:flutter/material.dart';
import 'package:vhv_shared/vhv_shared.dart';

class PanelDefault extends StatelessWidget {
  const PanelDefault({super.key,
    this.leading,
    required this.title,
    this.titleStyle,
    this.trailing,
    this.contentPadding,
    this.titlePadding,
    this.margin,
    this.backgroundColor,
    required this.child,
    this.bottom,
    this.hideDivider = false,
    this.showBorder = false
  });
  final Widget? leading;
  final Widget? trailing;
  final String title;
  final TextStyle? titleStyle;
  final EdgeInsets? contentPadding;
  final EdgeInsets? titlePadding;
  final EdgeInsets? margin;
  final Widget child;
  final Widget? bottom;
  final Color? backgroundColor;
  final bool hideDivider;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Card(
      color: backgroundColor,
      elevation: 0,
      margin: margin ?? EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: showBorder ? BorderSide(color: AppColors.dividerColor) : BorderSide.none
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: titlePadding ?? EdgeInsets.all(contentPaddingBase).copyWith(
              bottom: hideDivider ? 0 : contentPaddingBase
            ),
            child: Row(
              children: [
                if(leading != null)leading!.marginOnly(
                    right: 15
                ),
                Expanded(child: Text(title,
                  style: titleStyle ?? appTheme?.panelTitleStyle
                      ?? AppTextStyles.title,)
                ),
                if(trailing != null)trailing!.marginOnly(
                    left: 15
                )
              ],
            ),
          ),
          if(!hideDivider)const Divider(height: 1,),
          Padding(
            padding: contentPadding ?? EdgeInsets.all(contentPaddingBase),
            child: child,
          ),
          if(bottom != null)...[
            if(!hideDivider)const Divider(height: 1,),
            bottom!
          ]
        ],
      ),
    );
  }
}
