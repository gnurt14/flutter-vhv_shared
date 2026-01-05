import 'package:flutter/foundation.dart';

// enum ApplicationStatus{active, expired}
// enum UserStatus{active, loginVerify, guest}
class ApplicationStateNotifier extends ChangeNotifier {
  ApplicationStateNotifier._();
  static ApplicationStateNotifier? _instance;

  factory ApplicationStateNotifier(){
    _instance ??= ApplicationStateNotifier._();
    return _instance!;
  }

  // ApplicationStatus _appStatus = ApplicationStatus.active;
  // UserStatus _userStatus = UserStatus.active;
  //
  //
  // void setAppStatus([ApplicationStatus newStatus = ApplicationStatus.active]){
  //   _appStatus = newStatus;
  //   notifyListeners();
  // }
  //
  // void setUserStatus([UserStatus newStatus = UserStatus.active]){
  //   _userStatus = newStatus;
  //   notifyListeners();
  // }
  //
  // String? get redirect{
  //   switch(_appStatus){
  //     case ApplicationStatus.active:
  //       switch(_userStatus){
  //         case UserStatus.loginVerify:
  //           return '/Login/Verify';
  //         case UserStatus.active:
  //         case UserStatus.guest:
  //           return null;
  //       }
  //     case ApplicationStatus.expired:
  //       return '/Expired';
  //   }
  // }
  void refresh() {
    notifyListeners();
  }
}
