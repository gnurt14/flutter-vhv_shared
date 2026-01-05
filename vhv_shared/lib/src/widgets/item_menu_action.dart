import 'package:flutter/material.dart';

class ItemMenuAction {
  final String label;
  final IconData iconData;
  final bool showInItem;
  final bool? isPrimary;
  final bool enabled;
  final Function()? onPressed;
  final String? key;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool alwaysShowIcon;
  final Alignment? alignment;

  ItemMenuAction({
    required this.label,
    required this.iconData,
    this.showInItem = false,
    this.isPrimary,
    this.enabled = true,
    this.onPressed,
    this.key,
    this.alwaysShowIcon = false,

    this.foregroundColor,
    this.backgroundColor,
    this.borderColor,
    this.alignment,
  });

  @override
  String toString(){
    return 'ItemMenuAction(label: ${label}, iconData: ${iconData}, showInItem: $showInItem, isPrimary: $isPrimary, enabled: $enabled, onPressed: $onPressed, key: $key, alwaysShowIcon: $alwaysShowIcon)';
  }

  ItemMenuAction copyWith({
    String? label,
    IconData? iconData,
    bool? showInItem,
    bool? isPrimary,
    bool? enabled,
    Function()? onPressed,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? borderColor,
  }) {
    return ItemMenuAction(
      label: label ?? this.label,
      iconData: iconData ?? this.iconData,
      showInItem: showInItem ?? this.showInItem,
      isPrimary: isPrimary ?? this.isPrimary,
      enabled: enabled ?? this.enabled,
      onPressed: onPressed ?? this.onPressed,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
    );
  }
}

extension ListItemMenuActionExtension on List<ItemMenuAction>{
  List<ItemMenuAction> get firstPrimary{
    if(this.isNotEmpty){
       return [
         this.first.copyWith(isPrimary: true),
         ...this.sublist(1).map((e) => e.copyWith(
           isPrimary: false
         )),
       ];
    }
    return [];
  }
  List<ItemMenuAction> get lastPrimary{
    if(this.isNotEmpty){
      return [
        ...this.sublist(0, this.length - 1).map((e) => e.copyWith(
            isPrimary: false
        )),
        this.last.copyWith(isPrimary: true),
      ];
    }
    return [];
  }
}