import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:vhv_shared/vhv_shared.dart';

class MultiFloatingButtonAction extends StatefulWidget {
  const MultiFloatingButtonAction({super.key,
    required this.items,
    this.onAction,
    this.child,
    this.backgroundColor,
    this.foregroundColor,
  });
  final List<ItemMenuAction> items;
  final Function(String action)? onAction;
  final Widget? child;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  State<MultiFloatingButtonAction> createState() => _MultiFloatingButtonActionState();
}

class _MultiFloatingButtonActionState extends State<MultiFloatingButtonAction> {
  late ValueNotifier<bool> openCloseDial;
  @override
  void initState() {
    openCloseDial = ValueNotifier<bool>(false);
    super.initState();
  }

  @override
  void dispose() {
    openCloseDial.dispose();

    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      openCloseDial: openCloseDial,
      // overlayOpacity: 0.3,
      // overlayColor: AppColors.black.withValues(alpha: 0.3),
      children: [
        SpeedDialChild(
          labelWidget: Card(
            margin: EdgeInsets.zero,
            elevation: 5,
            shadowColor: Colors.black,
            clipBehavior: Clip.antiAlias,
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: widget.items.map<Widget>((e){
                  return Material(
                    color: e.backgroundColor ?? Colors.transparent,
                    elevation: 0,
                    child: InkWell(
                      onTap: e.enabled ? (){
                        openCloseDial.value = false;
                        e.onPressed?.call() ?? widget.onAction?.call(e.key ?? '');
                      } : null,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: contentPaddingBase + 2,
                            horizontal: paddingBase + 2
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Opacity(
                              opacity: 0.7,
                              child: Icon(e.iconData,
                                color: e.foregroundColor,
                                size: 24,
                              ),
                            ),
                            w8,
                            Text(e.label,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: e.foregroundColor
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          )
        )
      ],
      backgroundColor: widget.backgroundColor,
      foregroundColor: widget.foregroundColor,
      child: widget.child,
    );
  }
}
