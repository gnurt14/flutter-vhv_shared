import 'package:flutter/material.dart';
import 'package:vhv_config/vhv_config.dart';
import 'package:vhv_shared/vhv_shared.dart';

export 'utilities/account_box.dart';
export 'utilities/app_info_box.dart';
export 'utilities/avatar.dart';
export 'utilities/avatars.dart';
export 'utilities/setting_box.dart';
export 'utilities/time_ago.dart';
export 'utilities/dash_line.dart';

class NotificationIcon extends StatelessWidget {
  const NotificationIcon({super.key,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.isDotted = false,
    this.customLabel
  });
  final Function() onPressed;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsets? padding;
  final bool isDotted;
  final Widget Function(int val)? customLabel;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: AppInfo.notificationCounter,
        builder: (_, value, child) {
          return IconButton(
            onPressed: (){
              AppInfo.notificationCounter.value = 0;
              onPressed();
            },
            padding: padding,
            icon: Badge(
              backgroundColor: backgroundColor,
              isLabelVisible: value > 0,
              textColor: foregroundColor,
              padding: customLabel != null ? EdgeInsets.zero : null,
              label: isDotted ? null : customLabel != null ? customLabel!(value) : Text(
                '${(value > 9) ? '9+' : value}',
              ),
              child: icon??const Icon(ViIcons.bell),
            ),
          );
        }
    );
  }
}