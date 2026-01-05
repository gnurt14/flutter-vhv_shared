import 'dart:async';

import 'package:vhv_config/vhv_config.dart';
import 'package:vhv_navigation/vhv_navigation.dart';
import 'package:vhv_network/vhv_network.dart';
import 'package:vhv_shared/vhv_shared.dart';
import 'package:vhv_state/src/bloc.dart';
import 'package:vhv_state/src/extension.dart';
import 'package:vhv_state/src/helper.dart';
import 'package:vhv_state/src/services/account_service.dart';
import 'package:vhv_storage/vhv_storage.dart';

import '../base/base.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState>{
  static String saveKey = 'account';

  AccountBloc(this.authHandler):super(AccountState(
    data: _loadAccountInfo(),
    domain: _loadAccountSaveDomain()
  )){
    on<LoadAccount>(_loadAccount);
    on<UpdateAccountExtra>(_updateExtra);
    on<LoginAccount>(_loginAccount);
    on<UpdateAccount>(_updateAccount);
    on<UpdateAccountInfo>(_updateAccountInfo);
    on<RemoveInfoAccount>(_removeInfoAccount);
    on<LogoutAccount>(_logout);
    account = AccountService(this);
  }
  final AuthHandler authHandler;

  static Map<String, dynamic> _loadAccountInfo(){
    final data = Setting().get<Map>(saveKey);
    if(data is Map && data.isNotEmpty){
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }
  static String _loadAccountSaveDomain(){
    final data = Setting().get<String>('${saveKey}SaveDomain');
    if(data is String && data.isNotEmpty){
      return data;
    }
    return '';
  }

  Future<void> _loadAccount(LoadAccount event, Emitter emit)async{
    if(state.isLogin && !state.isLoggingOut) {
      final currentState = state;
      if((currentState.domain != AppInfo.rootAppDomain && currentState.domain != AppInfo.forceAppDomain)
      || authHandler.useSiteId && empty(AppInfo.id)){
        ///TODO Kiểm tra thay đổi domain hoặc không tồn tại siteId
        add(LogoutAccount(force: true));
      }else {
        bool isLogin = false;
        int count = 2;
        while(!isLogin && count > 0){
          isLogin = await AppCookieManager().hasLogin();
          if(!isLogin && count > 0){
            count--;
            await Future.delayed(Duration(seconds: 1));
          }
          if (count == 0 && !isLogin) {
            add(LogoutAccount(force: true));
          }
        }
      }
    }
  }
  Future<void> _loginAccount(LoginAccount event, Emitter emit)async{
    if(!state.isLoggingOut) {
      final data = Map<String, dynamic>.from(event.data);
      await Future.wait([
        Setting().put(saveKey, data),
        Setting().put('${saveKey}SaveDomain', event.domain),
      ]);
      if(authHandler.onBeforeLogin != null) {
        await authHandler.onBeforeLogin!(data);
      }
      emit(state.copyWith(
        data: Map<String, dynamic>.from(event.data),
        domain: event.domain,
      ));
      await account.checkCallback();
      if(authHandler.onLoggedIn != null) {
        await authHandler.onLoggedIn!(data);
      }
      if(authHandler.needFetchInfo){
        appNavigator.pushNamedAndRemoveAllUntil('/Loading');
        dynamic res;
        getInfo()async{
          res = await getAppInfo();
        }
        await Future.wait([
          getInfo(),
          Future.delayed(const Duration(seconds: 1))
        ]);
        await Future.delayed(const Duration(milliseconds: 300));
        if(res){
          _onLoginRedirect(event);
        }
      }else{
        _onLoginRedirect(event);
        
        getAppInfo();
      }
      event.completer?.complete();
    }
  }
  void _onLoginRedirect(LoginAccount event){
    authHandler.onLoginRedirect?.call(event.data);
    if(!empty(event.redirectURL) && ['/Account/ChangePassword'].firstWhereOrNull(
            (e) => event.redirectURL.toString().contains(e)) != null){
      final redirectURL = event.redirectURL != null && event.redirectURL!.contains('/Account/changePassword')
          ? '${AppInfo.domain}/page/Account/ChangePassword' : event.redirectURL;
      Future.delayed(Duration(milliseconds: 300),(){
        VHVRouter.goToMenu({'link': redirectURL},
          popAll: false

        );
      });
      return;
    }

  }
  Future<void> _updateAccount(UpdateAccount event, Emitter emit)async{
    if(state.isLogin && !state.isLoggingOut) {
      final data = Map<String, dynamic>.from(event.data);
      await Setting().put(saveKey, data);
      emit(state.copyWith(
        data: event.force
        ? Map<String, dynamic>.from(event.data) :
        <String, dynamic>{
          ...state.data,
          ...Map<String, dynamic>.from(event.data)
        },
      ));
    }
  }
  Future<void> _removeInfoAccount(RemoveInfoAccount event, Emitter emit)async{
    if(state.isLogin && !state.isLoggingOut && event.keys.isNotEmpty) {
      final newData = <String, dynamic>{...state.data};
      newData.removeWhere((k, v) => event.keys.contains(k));
      await Setting().put(saveKey, newData);
      emit(state.copyWith(
        data: newData,
      ));
    }
  }
  Future<void> _updateAccountInfo(UpdateAccountInfo event, Emitter emit)async{
    if(!state.isLoggingOut) {
      final data = Map<String, dynamic>.from(event.data);
      final newData = <String, dynamic>{
        ...state.data,
        ...data
      };
      emit(state.copyWith(
        data: newData,
      ));
      await Setting().put(saveKey, data);
    }
  }
  Future<void> _logout(LogoutAccount event, Emitter emit)async{

    if(!state.isLoggingOut) {
      emit(state.copyWith(
        isLoggingOut: true,
      ));
      if (event.force) {

      }
      await appPerformanceTrace?.start('user_logout');
      if(!event.localLogout){
        await call('Member.User.logout', requestMethod: RequestMethodType.get);
      }
      VHVNetwork.clearData();
      await Future.wait([
        Setting().delete(saveKey),
        Setting().delete('${saveKey}SaveDomain'),
      ]);
      if(authHandler.onBeforeLogout != null) {
        await authHandler.onBeforeLogout!();
      }
      emit(const AccountState(data: {}, domain: ''));
      if(!globalContext.mounted){
        return;
      }
      globalContext.configBloc.clearAllAlert();
      try{
        await getAppInfo();
      }catch(_){}
      if(event.onSuccess != null){
        await event.onSuccess!();
      }
      if(event.onRedirect != null || authHandler.onLogoutRedirect != null){
        if(event.onRedirect != null){
          await event.onRedirect!();
        }else{
          await authHandler.onLogoutRedirect!();
        }
      }else{
        try{
          goToHome();
        }catch(_){

        }
      }
      await account.checkCallback();
      AppInfo.resetCounter();
      if(authHandler.onLoggedOut != null) {
        try{
          await authHandler.onLoggedOut!();
        }catch(_){

        }
      }
      await appPerformanceTrace?.stop('user_logout');
    }
  }
  void _updateExtra(UpdateAccountExtra event, Emitter emit){
    emit(state.copyWith(
      needVerify: event.needVerify,
      passwordChangeRequired: event.passwordChangeRequired,
    ));
  }
  void setPasswordChangeRequired(bool need){
    add(UpdateAccountExtra(
      passwordChangeRequired: need
    ));
  }
  void setNeedVerify(bool need){
    add(UpdateAccountExtra(
        needVerify: need
    ));
  }

  @override
  void onChange(Change<AccountState> change) {
    if(
    (change.currentState.isLogin != change.nextState.isLogin)
    || (change.currentState.passwordChangeRequired != change.nextState.passwordChangeRequired)
    || (change.currentState.needVerify != change.nextState.needVerify)
     || (change.currentState.isLogin == change.nextState.isLogin
            && (change.currentState.isAdmin != change.nextState.isAdmin
                || change.currentState.isOwner != change.nextState.isOwner))
    ){
      ApplicationStateNotifier().refresh();
    }
    super.onChange(change);
  }


}