import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:vhv_config/vhv_config.dart';
import 'package:vhv_navigation/vhv_navigation.dart';
import 'package:vhv_network/vhv_network.dart';
import 'package:vhv_shared/vhv_shared.dart' as helper;
import 'package:vhv_shared/vhv_shared.dart';
import 'package:vhv_state/vhv_state.dart';
import 'package:vhv_storage/vhv_storage.dart';
import 'package:vhv_utils/vhv_utils.dart';


final class AccountService extends helper.AccountBase{
  AccountService._();
  static AccountService? _instance;
  factory AccountService(AccountBloc bloc){
    _bloc = bloc;
    _instance ??= AccountService._();
    return _instance!;
  }
  @override
  AuthHandler get authHandler => _bloc.authHandler;
  static late AccountBloc _bloc;
  AccountState get _state => _bloc.state;

  @override
  Map get data => _state.data;

  @override
  String get id => _state.id;
  @override
  String get fullName => _state.fullName;
  @override
  String get userId => _state.userId;
  @override
  String get phone => _state.phone;
  @override
  String get email => _state.email;
  @override
  String get address => _state.address;
  @override
  String get birthDate => _state.birthDate;
  @override
  String get code => _state.code;
  @override
  String get image => _state.image;
  @override
  String get passport => _state.passport;
  @override
  Map get accountLinks => _state.accountLinks;
  @override
  bool get isNeedVerify => _state.needVerify;
  @override
  bool get isPasswordChangeRequired => _state.passwordChangeRequired;

  @override
  void needVerify(bool need) {
    _bloc.setNeedVerify(need);
  }

  @override
  void passwordChangeRequired(bool need) {
    _bloc.setPasswordChangeRequired(need);
  }

  @override
  bool isLogin([BuildContext? context, bool listen = false]){
    if(context != null){
      if(listen) {
        return context
            .watch<AccountBloc>()
            .state
            .isLogin;
      }else{
        return context
            .read<AccountBloc>()
            .state
            .isLogin;
      }
    }
    return _state.isLogin;
  }

  @override
  bool isAdmin() => _state.isAdmin;

  @override
  bool isOwner() => _state.isOwner;
  @override
  bool get isLoggingOut => _state.isLoggingOut;
  @override
  Map getData(){
    return data;
  }

  @override
  void operator []=(String name, value) {
    _bloc.add(UpdateAccount(data: {
      name: value
    }));
  }

  @override
  void logout({
    bool localLogout = false,
    bool force = false,
    Function()? onRedirect,
    Function()? onSuccess,
  }){
    showLoading();
    _bloc.add(LogoutAccount(
      localLogout: localLogout,
      force: force,
      onRedirect: onRedirect,
      onSuccess: (){
        Setting('CacheData').clear();
        onSuccess?.call();
        needVerify(false);
        disableLoading();
      }
    ));
  }

  @override
  FutureOr<void> update(Map response) {
    if(response.containsKey('totalNewNotification')) {
      AppInfo.notificationCounter.value =
          parseInt(response['totalNewNotification']);
    }
    _bloc.add(UpdateAccount(data: response));
  }


  @override
  FutureOr<void> assign(Map response) {
    _bloc.add(UpdateAccount(data: response, force: true));
  }


  @override
  void remove(String key) {
    _bloc.add(RemoveInfoAccount(keys: [key]));
  }
  @override
  void removes(List<String> keys) {
    _bloc.add(RemoveInfoAccount(keys: keys));
  }

  @override
  Future requireLogin(BuildContext context, Future Function() onSuccess) async {
    if (isLogin()) {
      return await onSuccess();
    } else {
      if(!authHandler.requiredLogin) {
        await appNavigator.homePushNamedTo(authHandler.loginRouter);
      }else{
        await appNavigator.pushNamedAndRemoveAllUntil(authHandler.loginRouter);
      }
      await Future.delayed(const Duration(seconds: 1));
      if (isLogin()) {
        return await onSuccess();
      }
    }
    return null;
  }

  @override
  void toLogin([dynamic arguments]) {
    appNavigator.pushNamed(authHandler.loginRouter, arguments: arguments);
  }

  @override
  Future<dynamic> login(Map response) async {
    if(response['account'] is Map) {
      if(authHandler.useSiteId){
        if (!empty(response['site']) || !empty(response['account']['site'])) {
          await VHVNetwork.changeInfo(
            id: !empty(response['site']) ? response['site'] : response['account']['site'],
            title: response['siteTitle'],
          );
        }
      }
      await clearAllCache();
      cancelAllMessage();
      Completer<void> completer = Completer();
      await Setting('CacheData').clear();
      _bloc.add(LoginAccount(
        data: response['account'],
        redirectURL: response['redirectURL'],
        domain: AppInfo.domain,
        completer: completer
      ));
      await completer.future;
    }
  }

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
}
