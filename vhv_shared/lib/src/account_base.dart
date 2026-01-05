import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vhv_shared/vhv_shared.dart';

base class AccountBase {
  Map get data => {};
  String get id => '';
  String get code => '';
  String get fullName => '';
  String get userId => '';
  String get phone => '';
  String get email => '';
  String get address => '';
  String get birthDate => '';
  String get image => '';
  String get passport => '';
  Map get accountLinks => {};

  bool get isLoggingOut => false;

  bool get isNeedVerify => false;
  bool get isPasswordChangeRequired => false;

  final Map<String, Function()> _loginCallback = {};
  final Map<String, Function()> _logoutCallback = {};

  void setLogoutCallback(String key, Function() callback){
    _logoutCallback[key] = callback;
  }
  void setLoginCallback(String key, Function() callback){
    _loginCallback[key] = callback;
  }

  Future<void> checkCallback()async{
    if(isLogin()){
      await Future.forEach(_loginCallback.entries, (e)async{
        await e.value();
      });
    }else{
      await Future.forEach(_logoutCallback.entries, (e)async{
        await e.value();
      });
    }
  }

  AuthHandler get authHandler => const AuthHandler();

  bool isLogin([BuildContext? context, bool listen = false]) {
    return false;
  }

  Map getData(){
    return data;
  }

  dynamic operator [](String name) {
    if (data.containsKey(name)) {
      return data[name];
    }
    return '';
  }
  void operator []=(String name, value) {
  }

  bool isAdmin() {
    return false;
  }

  bool isOwner() {
    return false;
  }

  void needVerify(bool need){
    throw Exception('needVerify need Override');
  }
  void passwordChangeRequired(bool need){
    throw Exception('passwordChangeRequired need Override');
  }


  ///Ghi đè dữ liệu
  FutureOr<void> assign(Map response)async{}
  ///Cập nhật dữ liệu
  FutureOr<void> update(Map response)async{}
  void remove(String key){}
  void removes(List<String> keys){}
  void toLogin(){}

  Future<dynamic> login(Map response) async {}

  Future<void> requireLogin(BuildContext context, Future Function() onSuccess) async {}
  void logout({
    bool localLogout = false,
    bool force = false,
    Function()? onRedirect,
    Function()? onSuccess,
  }){}
  @override
  String toString() {
    if (isLogin()) {
      return '-----------------Account Info------------------->'
          '\n$fullName'
          '\ncode: $code'
          '\naccountId: $id'
          '\nuserId: $userId'
          '\nbirthDate: $birthDate'
          '\nphone: $phone'
          '\nemail: $email'
          '\naddress: $address'
          '\n-----------------Account Info------------------->';
    }
    return 'Guest';
  }
  @Deprecated('Not use')
  Function? onLogoutSuccess;
  @Deprecated('Not use')
  Function? onLoginSuccess;
}