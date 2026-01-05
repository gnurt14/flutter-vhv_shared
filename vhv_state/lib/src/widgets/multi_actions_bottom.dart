import 'package:flutter/material.dart';
import 'package:vhv_navigation/vhv_navigation.dart';
import 'package:vhv_shared/vhv_shared.dart';

enum MultiActionsBottomType{type1, type2, type3}
class MultiActionsBottom extends StatelessWidget {
  const MultiActionsBottom({super.key,
    required this.actions,
    this.onChanged,
    this.extraTop,
    this.maxVisibleButton = 2,
    this.hasDivider = true,
    this.padding,
    this.isMultiSave,
    this.useSafeArea = true,
    this.backgroundColor,
    this.type = MultiActionsBottomType.type1
  }) : assert(isMultiSave == false || maxVisibleButton > 1);
  final List<ItemMenuAction> actions;
  final ValueChanged<String>? onChanged;
  final Widget? extraTop;
  final int maxVisibleButton;
  final bool hasDivider;
  final EdgeInsets? padding;
  final bool? isMultiSave;
  final bool useSafeArea;
  final Color? backgroundColor;
  final MultiActionsBottomType type;

  @override
  Widget build(BuildContext context) {
    if(actions.isEmpty){
      return const SizedBox.shrink();
    }
    return _ActionsBox(
      isMultiSave: isMultiSave,
      maxVisibleButton: maxVisibleButton,
      actions: actions,
      hasDivider: hasDivider,
      padding: padding,
      onChanged: onChanged?.call ?? (_){},
      extraTop: extraTop,
      useSafeArea: useSafeArea,
      backgroundColor: backgroundColor,
      type: type,
      actionLeft: hasExtra ? BaseButton.outlinedIcon(
        style: isType2 ? OutlinedButton.styleFrom(
            foregroundColor: AppColors.textColor,
          side: BorderSide(color: AppColors.border)
        ) : OutlinedButton.styleFrom(
          fixedSize: const Size.fromWidth(48),
          minimumSize: const Size.fromWidth(48),
          maximumSize: const Size.fromWidth(48),
          padding: EdgeInsets.zero
        ),
        label: isType2 || isType3 ? Text('Khác'.lang()) : const Icon(ViIcons.dots_vertical),
        icon: isType2 ? const Icon(ViIcons.dots_vertical) : null,
        onPressed: (){
          showActions(context);
        }
      ) : null,
    );
  }
  
  bool get isType2 => type == MultiActionsBottomType.type2;
  bool get isType3 => type == MultiActionsBottomType.type3;

  bool get hasExtra => actions.length > maxVisibleButton;

  @protected
  void showActions(BuildContext context){
    AppBottomSheets().show(
      padding: EdgeInsets.zero,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: actions.skip(isType3 ? 1 : 2 ).map<Widget>((e){
            return Material(
              color: Theme.of(context).cardColor,
              child: ListTile(
                minTileHeight: 0,
                contentPadding: EdgeInsets.symmetric(
                    vertical: paddingBase/1.5,
                    horizontal: paddingBase
                ),
                leading: Icon(e.iconData, size: 20, color: (e.key == 'delete' || e.key == 'deleteAll') ? AppColors.delete : null,),
                horizontalTitleGap: 12,
                title: Text(e.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: (e.key == 'delete' || e.key == 'deleteAll') ? AppColors.delete : null,
                  ),
                ),
                onTap: (){
                  if(e.onPressed != null) {
                    appNavigator.pop();
                    e.onPressed?.call();
                  }else{
                    appNavigator.pop(e.key);
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    ).then((res){
      if(context.mounted && res is String) {
        onChanged?.call(res);
      }
    });
  }
}

class _ActionsBox extends StatelessWidget {
  final List<ItemMenuAction> actions;
  final Widget? extraTop;
  final Widget? actionLeft;
  final int maxVisibleButton;
  final bool hasDivider;
  final EdgeInsets? padding;
  final ValueChanged<String> onChanged;
  final bool? isMultiSave;
  final bool useSafeArea;
  final Color? backgroundColor;
  final MultiActionsBottomType type;
  const _ActionsBox({
    required this.actions,
    required this.onChanged,
    this.extraTop,
    this.hasDivider = true,
    this.actionLeft,
    this.maxVisibleButton = 2,
    this.padding,
    this.isMultiSave,
    this.useSafeArea = true,
    this.backgroundColor,
    required this.type
    
  });

  bool get isType2 => type == MultiActionsBottomType.type2;
  bool get isType3 => type == MultiActionsBottomType.type3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).bottomNavigationBarTheme;
    List<ItemMenuAction> fixedItems = <ItemMenuAction>[];
    if(isType3) {
      fixedItems = [...actions.take(actions.length > 2 ? 1 : actions.length)];
    } else {
      fixedItems = [...actions.take(maxVisibleButton)];
    }
    fixedItems = fixedItems.reversed.toList();
    final listWidget = <Widget>[];
    Widget getBtn(ItemMenuAction data){
      final index = fixedItems.indexOf(data);
      final last = index == (maxVisibleButton - 1) || (index == fixedItems.length - 1);
      final isPrimary = (data.isPrimary == true || (last && data.isPrimary == null));
      return SizedBox(
          height: 48,
          child: isPrimary ? BaseButton.icon(
            onPressed: data.enabled ? (data.onPressed ?? (){
              onChanged(data.key ?? '');
            }) : null,
            style:  ElevatedButton.styleFrom(
                foregroundColor: data.foregroundColor,
                backgroundColor: data.backgroundColor
            ),
            label: Text(data.label),
            icon: (data.alwaysShowIcon || isType2) ? Icon(data.iconData) : null,
          ) : BaseButton.outlinedIcon(
            onPressed: data.enabled ? (data.onPressed ?? (){
              onChanged(data.key ?? '');
            }) : null,
            style: OutlinedButton.styleFrom(
                foregroundColor: data.foregroundColor,
                backgroundColor: data.backgroundColor,
                side: data.foregroundColor != null ? BorderSide(color: data.borderColor ?? data.foregroundColor!) : null
            ),
            label: Text(data.label),
            icon: (data.alwaysShowIcon || isType2) ? Icon(data.iconData) : null,
          )
      );
    }
    for (var data in fixedItems) {
      final btn = getBtn(data);
      listWidget.add(Expanded(
        child: data.alignment != null ? Align(
          alignment: data.alignment!,
          child: btn,
        ) : btn,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.backgroundColor ?? Theme.of(context).cardColor,
        border: hasDivider ? Border(
          top: BorderSide(
            color: context.isDarkMode ? AppColors.gray600 : AppColors.gray300,
            width: 0.5
          )
        ) : null
      ),
      child: SafeArea(
        top: false,
        bottom: useSafeArea ? true : false,
        child: Padding(
          padding: (padding ?? EdgeInsets.all(paddingBase)).copyWith(
            left: (isMultiSave is bool && actionLeft == null) ? 0 : null
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if(extraTop != null)extraTop!,
              if(!isType3)...[
                if(actionLeft != null && isType2)...[
                  Row(
                    children: [
                      if(actions.length > 3)Expanded(child: SizedBox(
                        height: 48,
                        width: double.infinity,
                        child: actionLeft,
                      )),
                      if(actions.length == 3)Expanded(child: getBtn(actions.elementAt(2))),
                      if(listWidget.lastOrNull != null)...[
                        w16,
                        listWidget.firstOrNull!
                      ]
                    ],
                  ),
                  h16
                ],
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: Row(
                    children: [
                      if(!isType2)...[
                        if(actionLeft != null)...[
                          SizedBox(
                            height: 48,
                            child: actionLeft,
                          ),
                          w16
                        ],
                        if(isMultiSave is bool)...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(value: isMultiSave, onChanged: (val){
                                onChanged('saveAndAddNext');
                              }),
                              Flexible(child: Text('Lưu & thêm tiếp'.lang(),
                                style: const TextStyle(
                                    fontSize: 16
                                ),
                              ))
                            ],
                          ),
                          w16
                        ],
                        ...listWidget.insertBetween(SizedBox(width: contentPaddingBase, height: contentPaddingBase,)),
                      ],
                      if(isType2)...[
                        listWidget.lastOrNull ?? SizedBox.shrink()
                      ]
                    ],
                  ),
                ),
              ] else...[
                 Row(
                   children: [
                     if(actionLeft != null)...[
                       Expanded(child: SizedBox(
                         height: 48,
                         width: double.infinity,
                         child: actionLeft,
                       )),
                       w16,
                     ],
                     ...listWidget.insertBetween(SizedBox(width: contentPaddingBase, height: contentPaddingBase,)),
                   ],
                 )
              ]
            ],
          ),
        ),
      ),
    );
  }
}