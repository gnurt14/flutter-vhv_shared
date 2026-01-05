import 'package:flutter/material.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

class BottomNavigationBarBase extends StatelessWidget{
  final Widget? child;
  final List<Widget>? children;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final ValueChanged<bool>? onHover;
  final ButtonStyle? style;
  final EdgeInsetsGeometry? padding;
  const BottomNavigationBarBase.button({
    super.key,
    required this.child,
    required this.onPressed,
    this.onLongPress,
    this.onHover,
    this.style,
    this.padding
  }) : children = null;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Builder(
        builder: (_){
          if(child != null){
            return Padding(
              padding: padding ?? EdgeInsets.all(paddingBase),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: BaseButton(
                  onPressed: onPressed,
                  onLongPress: onLongPress,
                  onHover: onHover,
                  style: style,
                  child: child,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}