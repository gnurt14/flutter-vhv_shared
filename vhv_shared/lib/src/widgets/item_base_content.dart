import 'package:flutter/material.dart';
import 'package:vhv_shared/vhv_shared.dart';
class ContentLineInfo{
  final String label;
  final dynamic value;
  final String defaultValue;
  final Color? color;
  final Color? labelColor;
  final Color? forceColor;
  final IconData? iconData;
  final Widget Function(Widget child)? wrapBuilder;
  final Widget? child;
  final FontWeight? fontWeight;
  final double? fontSize;
  const ContentLineInfo(this.label, this.value, {
    this.color,
    this.labelColor,
    this.forceColor,
    this.defaultValue = '--', this.iconData,
    this.wrapBuilder,
    this.fontWeight,
    this.fontSize,
    this.child
  })
      : assert(value is Widget || value == null || value is num || value is String || value is List || value is Function());

}
enum _ItemBaseContentType{basic, twoLines, wrap}
class ItemBaseContent extends StatelessWidget {
  const ItemBaseContent({super.key,
    required this.items,
    this.hasDivider = true,
    this.useExpanded = true,
    this.style,
    this.labelSuffix,
    this.labelPrefix,
    this.space,
    this.colorDivider,
    this.iconSize,
    this.iconLabelSpacing,
  }) : _type = _ItemBaseContentType.basic,
      runSpace = null,
      leadingBuilder = null
  ;
  final List<ContentLineInfo> items;
  final bool hasDivider;
  final bool useExpanded;
  final TextStyle? style;
  final String? labelSuffix;
  final String? labelPrefix;
  final _ItemBaseContentType _type;
  final double? space;
  final double? runSpace;
  final Color? colorDivider;
  final Widget Function(IconData? iconData)? leadingBuilder;
  final double? iconSize;
  final double? iconLabelSpacing;

  const ItemBaseContent.twoLines({
    super.key,
    required this.items,
    this.hasDivider = false,
    this.style,
    this.labelSuffix,
    this.labelPrefix,
    this.space,
    this.colorDivider,
    this.leadingBuilder,
    this.iconSize,
    this.iconLabelSpacing,
  }) : _type = _ItemBaseContentType.twoLines,
      useExpanded = false,
      runSpace = null
  ;

  const ItemBaseContent.wrap({
    super.key,
    required this.items,
    this.style,
    this.labelSuffix,
    this.labelPrefix,
    this.space,
    this.colorDivider,
    this.runSpace,
    this.iconSize,
    this.iconLabelSpacing,
    this.hasDivider = false,
  }) : _type = _ItemBaseContentType.wrap,
      useExpanded = false,
        leadingBuilder = null
  ;

  @override
  Widget build(BuildContext context) {
    if(_type == _ItemBaseContentType.wrap){
      return Wrap(
        spacing: space ?? paddingBase,
        runSpacing: runSpace ?? paddingBase/2,
        children: List<Widget>.generate(items.length, (index) {
          final e = items.elementAt(index);
          return e.wrapBuilder != null ? e.wrapBuilder!(child(context, e)) : child(context, e);
        })
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(items.length, (index){
        final e = items.elementAt(index);
        if(hasDivider){
          return Container(
            width: (useExpanded) ? double.infinity : null,
            padding: EdgeInsets.symmetric(
                vertical: (space ?? paddingBase)/2
            ),
            decoration: index != 0 ? BoxDecoration(
                border: Border(top: BorderSide(color: colorDivider ?? AppColors.dividerColor))
            ) : null,
            child: e.child != null ? Align(
              alignment: Alignment.centerLeft,
              child: e.child,
            ) : (e.wrapBuilder != null ? e.wrapBuilder!(child(context, e)) : child(context, e)),
          );
        }
        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: (space ?? contentPaddingBase)/2
          ),
          child: e.child ?? (e.wrapBuilder != null ? e.wrapBuilder!(child(context, e)) : child(context, e)),
        );
      }).toList(),
    );
  }

  Widget child(BuildContext context, ContentLineInfo e){
    switch(_type){
      case _ItemBaseContentType.twoLines:
        return SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              if(leadingBuilder != null)leadingBuilder!.call(e.iconData),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    labelText(context, e).marginOnly(
                        bottom: 4
                    ),
                    valueWidget(context, e)
                  ],
                ),
              )
            ],
          ),
        );
      case _ItemBaseContentType.wrap:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            labelText(context, e).marginOnly(
                right: 4
            ),
            valueWidget(context, e)
          ],
        );
      default:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            labelText(context, e).marginOnly(
                right: useExpanded ? 15 : 10
            ),
            if(useExpanded)Expanded(child: valueWidget(context, e)),
            if(!useExpanded)Flexible(child: valueWidget(context, e))
          ],
        );
    }

  }

  Widget labelText(BuildContext context, ContentLineInfo e){
    final color = e.forceColor ?? e.labelColor ?? (context.isDarkMode ? AppColors.gray300 : AppColors.gray500);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if(e.iconData != null && leadingBuilder == null)Icon(e.iconData, size: iconSize ?? 20, color: color,).marginOnly(
          right: iconLabelSpacing ?? 8
        ),
        Text('${labelPrefix ?? ''}${e.label.lang()}${labelSuffix ?? ''}',
          style: TextStyle(
            color: color,
          )
        )
      ],
    );
  }

  Widget valueWidget(BuildContext context, ContentLineInfo e){
    if(e.value is Widget){
      return e.value as Widget;
    }
    final val = e.value is Function() ? e.value()
        : '${e.value is List ? (e.value as List).join(', ') : e.value ?? ''}';
    if(val is Widget){
      return val;
    }
    return Text(!empty(val, true) ? val : e.defaultValue,
      style: style ?? TextStyle(
        fontSize: e.fontSize,
        fontWeight: e.fontWeight,
        color: e.forceColor ?? e.color ?? (context.isDarkMode ? AppColors.white : AppColors.gray900),
      ),
      textAlign: useExpanded ? TextAlign.right : null,
    );
  }
}
