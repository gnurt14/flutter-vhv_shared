import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

class AppLoadingManager{
  AppLoadingManager._();
  static AppLoadingManager? _instance;
  static AppLoadingManager get instance{
    _instance ??= AppLoadingManager._();
    return _instance!;
  }
  bool get isShowLoading => _isShowLoading;
  static bool _isShowLoading = false;
  void Function() showLoading = _showLoading;
  static void _showLoading(){
    try {
    BotToast.showLoading();
    _isShowLoading = true;
    }catch(_){}
  }
  void Function() disableLoading = _disableLoading;
  static void _disableLoading(){
    try{
      BotToast.closeAllLoading();
      _isShowLoading = false;
    }catch(_){}
  }
  void Function({
    required ToastBuilder toastBuilder,
    Color? backgroundColor
  }) showCustomLoading = _showCustomLoading;
  static void _showCustomLoading({
    required ToastBuilder toastBuilder,
    Color? backgroundColor
  }){
    BotToast.showCustomLoading(
      toastBuilder: toastBuilder,
      backgroundColor: backgroundColor??Colors.black.withValues(alpha: 0.2),
      useSafeArea: false
    );
    _isShowLoading = true;
  }
  void cancelAllMessage() {
    try {
      BotToast.cleanAll();
      _isShowLoading = false;
    }catch(_){}
  }
}