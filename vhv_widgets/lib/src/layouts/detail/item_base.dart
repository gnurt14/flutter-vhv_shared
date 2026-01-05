import 'package:flutter/material.dart';
import 'package:vhv_state/vhv_state.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

class ItemBase extends StatelessWidget {
  const ItemBase({super.key,
    this.onPressed,
    this.onLongPress,
    this.isSelected,
    this.content,
    this.leading,
    this.trailing,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.padding = const EdgeInsets.all(12),
    this.showMultiActions = true,
    this.title,
    this.titleText,
    this.actions = const [],
    this.onAction,
    this.isActive = false,
    this.backgroundColor,
    this.borderRadius,
    this.elevation,
  });
  final BorderRadiusGeometry? borderRadius;
  final Function()? onPressed;
  final Function()? onLongPress;
  final Function(BuildContext context, String key)? onAction;
  final bool? isSelected;
  final Widget? content;
  final Color? backgroundColor;
  final Widget? leading;
  final Widget? trailing;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsets padding;
  final bool showMultiActions;
  final Widget? title;
  final String? titleText;
  final List<ItemMenuAction> actions;
  final bool isActive;
  final double? elevation;

  bool get hasShowActions => actions.isNotEmpty && showMultiActions;

  @override
  Widget build(BuildContext context) {
    final onTap = isSelected is bool ? onLongPress : onPressed;
    return BoxContent(
      elevation: elevation ?? 0,
      borderRadius: borderRadius,
      color: backgroundColor,
      isActive: isActive,
      child: InkWell(
        onTap: onTap != null ? (){
          FocusScope.of(context).requestFocus(FocusNode());
          onTap.call();
        } : null,
        onLongPress: onLongPress,
        hoverColor: darken(backgroundColor ?? Theme.of(context).cardColor, 0.02),
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),

        child: Stack(
          children: [
            Padding(
              padding: padding,
              child: Row(
                crossAxisAlignment: crossAxisAlignment,
                children: [
                  _leading(context),
                  Expanded(
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (title != null || titleText != null)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (titleText != null)
                                          Text(
                                            titleText!,
                                            style: AppTextStyles.title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                          ).marginOnly(bottom: 5),

                                        if (title != null)...[
                                          // h8,
                                          title!,
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (hasShowActions || !empty(trailing))
                                    const SizedBox(width: 40),
                                ],
                              ),
                            if(content != null)content!,
                          ],
                        )

                      ],
                    ),
                  ),
                  if(title == null && titleText == null) _trailing(
                      context, hasShowActions),

                ],
              ),
            ),
            (trailing != null)
                ? Positioned(top: 5,
                right: 0, child: trailing!)
                : (showMultiActions && (title != null || titleText != null))
                ? Positioned(
                top: 0,
                right: 0,
                child: _trailing(context, hasShowActions)
            )
                : const SizedBox.shrink()
          ],
        ),
      ),
    );
  }

  Widget _trailing(BuildContext context, bool showMultiActions) {
    if (trailing != null) {
      return trailing!;
    }
    if (showMultiActions) {
      return IconButton(
          onPressed: isSelected == null ? () {
            showBottomAction(context, actions: actions, onAction: onAction??(_,_) {});
          } : null,
          style: IconButton.styleFrom(
            padding: EdgeInsets.zero,
            fixedSize: const Size(40, 40),
            minimumSize: const Size(40, 40),
          ),
          icon: const Icon(ViIcons.dots_vertical_solid)
      ).marginOnly(
          left: padding.left
      );
    }
    return const SizedBox.shrink();
  }

  Widget _leading(BuildContext context) {
    if (isSelected is bool) {
      return SizedBox(
        width: 25,
        height: 25,
        child: IgnorePointer(
          ignoring: true,
          child: Checkbox(value: isSelected, onChanged: (val) {}),
        ),
      ).marginOnly(
          right: contentPaddingBase
      );
    }
    if (leading != null) {
      return leading!.marginOnly(
          right: contentPaddingBase
      );
    }
    return const SizedBox.shrink();
  }
}
