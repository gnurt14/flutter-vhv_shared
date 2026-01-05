import 'package:flutter/material.dart';
import 'package:vhv_widgets/vhv_widgets.dart';


class ItemListBase extends StatelessWidget {
  final GestureTapCallback? onTap;
  final GestureTapCallback? onLongPress;
  final Widget? title;
  final Widget? leading;
  final Widget? trailing;
  final Widget? subtitle;
  final EdgeInsetsGeometry? contentPadding;
  final List<ItemListAction>? actions;
  final bool? isSelected;
  final bool enabled;
  final Color? color;
  final Color? hoverColor;
  final bool isFullHeight;

  const ItemListBase({super.key, this.onTap,
    required this.title, this.leading,
    this.trailing, this.onLongPress,
    this.subtitle, this.actions,
    this.contentPadding, this.isSelected,
    this.enabled = true, this.color,this.hoverColor,
    this.isFullHeight = false});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: color,
        child: InkWell(
        onTap: (isSelected != null)?onLongPress:onTap,
        onLongPress: onLongPress,
          hoverColor: hoverColor ?? Colors.white,
        child: Container(
          padding: contentPadding?? const EdgeInsets.symmetric(
              vertical: 3,
              horizontal: 10
          ).copyWith(right: (isSelected == null && actions != null)?0:10),
          constraints: const BoxConstraints(
            minHeight: 45
          ),
          height: isFullHeight?double.infinity:null,
          child: Row(
              crossAxisAlignment: isFullHeight?CrossAxisAlignment.start:CrossAxisAlignment.center,
            children: [
              if(leading != null)leading!,
              if(leading != null)const SizedBox(width: 10),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if(title != null)DefaultTextStyle(
                    style: Theme.of(context).textTheme.titleSmall!,
                    child: title!,
                  ),
                  if(subtitle != null)DefaultTextStyle(
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.normal,
                      color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.8)
                    ),
                    child: subtitle!,
                  )
                ],
              )),
              Builder(
                builder: (_){
                  if(isSelected != null){
                    if(isSelected!){
                      return Icon(Icons.check_circle_outline_outlined,
                        color: Theme.of(context).floatingActionButtonTheme.backgroundColor);
                    }else{
                      return const Icon(Icons.radio_button_unchecked);
                    }
                  }else{
                    if(!empty(actions)){
                      return IconButton(icon: const Icon(Icons.more_vert), onPressed: enabled?(){
                        showBottomMenu(
                            child: SizedBox(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: actions!.map<Widget>((action){
                                  return InkWell(
                                    onTap: (){
                                      appNavigator.pop();
                                      action.onTap!();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if(action.icon != null)IconTheme(
                                            data: IconThemeData(
                                                color: action.color
                                            ),
                                            child: action.icon!,
                                          ),
                                          if(action.icon != null && action.title != null)const SizedBox(width: 10),
                                          if(action.title != null)Text(lang(action.title!), style: Theme.of(context).textTheme.titleMedium!.copyWith(color: action.color)),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            )
                        );
                      }:null);
                    }
                  }
                  if(trailing != null){
                    return trailing!;
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      )
    );
  }
}
class ItemListAction{
  final Widget? icon;
  final String? title;
  final GestureTapCallback? onTap;
  final Color? color;

  ItemListAction({this.color, this.icon, this.title,required this.onTap});
}
