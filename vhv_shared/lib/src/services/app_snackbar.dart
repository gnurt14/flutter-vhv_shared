import 'package:flutter/material.dart';
import 'package:vhv_shared/vhv_shared.dart';

class AppSnackbar {
  AppSnackbar._();
  static AppSnackbar? _instance;
  factory AppSnackbar() {
    _instance ??= AppSnackbar._();
    return _instance!;
  }

  bool _isDarkMode = false;
  bool get _useDarkMode => _isDarkMode || ThemeData().brightness == Brightness.dark;

  void setDarkMode(bool useDarkMode) {
    _isDarkMode = useDarkMode;
  }

  void show(String message, {
    Duration? duration,
    Widget? messageText,
    Function()? onButtonPressed,
    String? buttonText,
    bool? useDarkMode,
    Icon? icon,
    dynamic snackPosition,
    Alignment alignment = Alignment.bottomCenter}) {
    alignment = _convert(snackPosition, alignment);
    _showSnackbar(
      message,
      duration: duration,
      messageText: messageText,
      onButtonPressed: onButtonPressed,
      buttonText: buttonText,
      useDarkMode: useDarkMode,
      icon: icon,
      alignment: alignment,
    );
  }

  void information(String message, {Duration? duration, Function()? onButtonPressed, String? buttonText, bool? useDarkMode,
    dynamic snackPosition,
    Alignment alignment = Alignment.bottomCenter}) {
    alignment = _convert(snackPosition, alignment);
    _showSnackbar(
      message,
      duration: duration,
      onButtonPressed: onButtonPressed,
      buttonText: buttonText,
      useDarkMode: useDarkMode,
      icon: Icon(ViIcons.info_circle, color: AppColors.blue[400], size: 28),
      alignment: alignment,
    );
  }

  void fail(String message, {Duration? duration, Function()? onButtonPressed, String? buttonText, bool? useDarkMode, dynamic snackPosition,
    Alignment alignment = Alignment.bottomCenter}) {
    alignment = _convert(snackPosition, alignment);
    _showSnackbar(
      message,
      duration: duration,
      onButtonPressed: onButtonPressed,
      buttonText: buttonText,
      useDarkMode: useDarkMode,
      icon: Icon(ViIcons.alert_triangle, color: AppColors.red[400], size: 28),
      alignment: alignment,
    );
  }

  void warning(String message, {Duration? duration, Function()? onButtonPressed, String? buttonText, bool? useDarkMode,
    dynamic snackPosition,
    Alignment alignment = Alignment.bottomCenter}) {
    alignment = _convert(snackPosition, alignment);
    _showSnackbar(
      message,
      duration: duration,
      onButtonPressed: onButtonPressed,
      buttonText: buttonText,
      useDarkMode: useDarkMode,
      icon: Icon(ViIcons.alert_circle, color: AppColors.yellow[400], size: 28),
      alignment: alignment,
    );
  }

  void success(String message, {Duration? duration, Function()? onButtonPressed, String? buttonText, bool? useDarkMode,
    dynamic snackPosition,
    Alignment alignment = Alignment.bottomCenter
  }) {
    alignment = _convert(snackPosition, alignment);
    _showSnackbar(
      message,
      duration: duration,
      onButtonPressed: onButtonPressed,
      buttonText: buttonText,
      useDarkMode: useDarkMode,
      icon: Icon(ViIcons.check_circle, color: AppColors.green[400], size: 28),
      alignment: alignment,
    );
  }

  Alignment _convert(dynamic snackPosition, Alignment defaultValue){
    if(snackPosition is Enum){
      final val = snackPosition.name;
      if(val == 'TOP'){
        return Alignment.topCenter;
      }else{
        return Alignment.bottomCenter;
      }
    }
    return defaultValue;
  }



  void _showSnackbar(String message, {
    Duration? duration,
    Widget? messageText,
    Function()? onButtonPressed,
    String? buttonText,
    bool? useDarkMode,
    Icon? icon,
    Alignment alignment = Alignment.bottomCenter,
  }) {
    BotToast.showCustomText(
      duration: duration ?? const Duration(seconds: 5),
      backgroundColor: useDarkMode == true ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.2),
      toastBuilder: (cancelFunc) => Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: (useDarkMode ?? _useDarkMode) ? AppColors.gray[700] : AppColors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: AppBoxShadow.shadowLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  icon,
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: messageText ?? Text(
                    message,
                    style: TextStyle(
                      color: (useDarkMode ?? _useDarkMode) ? AppColors.white : AppColors.gray900,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (onButtonPressed != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    try{
                      cancelFunc();
                      onButtonPressed();
                    }catch(_){

                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: _useDarkMode ? AppColors.white : AppColors.primary,
                  ),
                  child: Text(buttonText ?? "Hủy".lang(), style: const TextStyle(fontWeight: FontWeight.w500)),
                ),
              ),
          ],
        ),
      ),
      align: alignment,
    );
  }
  
}