import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vhv_navigation/src/navigator_service.dart';
import 'package:vhv_shared/vhv_shared.dart';

final appNavigator = NavigatorService.instance;

Future checkLoginFunction(Function func) async {
  return account.requireLogin(globalContext, ()async{
    await func();
  });
}

FutureOr<void> goToHome([
  @Deprecated("not use")
  Duration? duration]){
  AppLoadingManager.instance.disableLoading();
  appNavigator.goToHome();
}

class MyNavigatorObserver extends NavigatorObserver {
  MyNavigatorObserver._();

  static MyNavigatorObserver? _instance;


  static bool mounted = false;

  factory MyNavigatorObserver(){
    mounted = true;
    _instance ??= MyNavigatorObserver._();
    return _instance!;
  }

  int _bottomSheetCount = 0;
  int _dialogCount = 0;

  bool get isBottomSheetOpen => _bottomSheetCount > 0;

  bool get isDialogOpen => _dialogCount > 0;

  bool get isOverlayOpen => isBottomSheetOpen || isDialogOpen;

  @override
  void didPush(Route route, Route? previousRoute) {
    _handleRouteChange(route, isPush: true);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _handleRouteChange(route, isPush: false);
  }
  void _handleRouteChange(Route route, {required bool isPush}) {
    final type = route.runtimeType.toString();
    if (type.contains('ModalBottomSheetRoute') ||
        type.contains('PersistentBottomSheetRoute')) {
      _bottomSheetCount += isPush ? 1 : -1;
      _bottomSheetCount = _bottomSheetCount.clamp(0, double.infinity).toInt();
    }

    if (type.contains('DialogRoute')) {
      _dialogCount += isPush ? 1 : -1;
      _dialogCount = _dialogCount.clamp(0, double.infinity).toInt();
    }
  }
}
bool get isBottomSheetOpen{
  try{
    if(MyNavigatorObserver.mounted) {
      return MyNavigatorObserver().isBottomSheetOpen;
    }
    return false;
  }catch(e){
    return false;
  }
}
bool get isDialogOpen{
  try{
    if(MyNavigatorObserver.mounted) {
      return MyNavigatorObserver().isDialogOpen;
    }
    return Navigator.of(globalContext).overlay?.mounted == true &&
        Navigator.of(globalContext).overlay!.context.widget.toString().contains('Dialog');
  }catch(e){
    return false;
  }
}
