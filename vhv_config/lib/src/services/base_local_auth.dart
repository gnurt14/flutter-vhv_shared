import 'dart:convert';

import 'package:vhv_config/vhv_config.dart';
import 'package:vhv_network/vhv_network.dart';
import 'package:vhv_shared/vhv_shared.dart';
import 'package:vhv_storage/vhv_storage.dart';
import 'package:vhv_utils/vhv_utils.dart';

abstract class BaseLocalAuth{
  BaseLocalAuth();

  List<AuthType> availableBiometrics = [];
  bool get biometricSupported => availableBiometrics.isNotEmpty && enabled;
  bool get isFace => availableBiometrics.contains(AuthType.face);
  bool get isFingerprint => availableBiometrics.contains(AuthType.fingerprint);

  Future<bool> get canCheckBiometrics => Future.value(false);
  bool _canCheck = false;
  bool get canCheck => _canCheck;

  String get lastLoginUser => _lastLoginUser;
  String _lastLoginUser = '';

  bool get enabled => _enabled;
  bool _enabled = false;
  String _encryption(String source){
    return base64.encode(utf8.encode(source));
  }
  String get _lastLoginUserCodeKey => _encryption('${AppInfo.rootAppDomain}/lastLoginUserCode');

  Map get localAuthUserInfo => checkType<Map>(Setting().get('localAuthUserInfo')) ?? {};

  String get deviceId => AppInfo.deviceId;

  Future<void> showLoginBiometric(String accountCode, [Function(Map response)? fallbackFunction])async{
    if(enabled && canCheck && !empty(accountCode)){
      if(await checkRegistered(accountCode)){
        await loginWithToken(accountCode, fallbackFunction);
      }
    }
  }

  Future<bool> checkRegistered([String? accountCode])async{
    if((empty(accountCode) && !account.isLogin()) || (accountCode != lastLoginUser)){
      return false;
    }else {
      final token = await AppSecureStorage().get('loginToken',
          accountName: _storageName(!empty(accountCode) ? accountCode! : account.code)
      );
      return token != null;
    }
  }
  Future<void> _getLastLoginUser()async{
    _lastLoginUser = (await AppSecureStorage().get(_lastLoginUserCodeKey)) ?? '';
  }

  Future<void> _setLoginUser(String code)async{
    try {
      await AppSecureStorage().put(_lastLoginUserCodeKey, code);
      _lastLoginUser = code;
    }catch(_){}
  }

  Future<bool> register()async{
    if(empty(AppInfo.deviceId)){
      return false;
    }
    if(await authBiometric()) {
      showLoading();
      final res = await call('Core.User.DeviceToken.register', params: {
        'uniqueDeviceId': AppInfo.deviceId
      });
      disableLoading();
      if(res is Map && res['status'] == 'SUCCESS' && account.isLogin()) {
        if (!empty(res['loginToken'])) {
          await saveToken(res['loginToken'],
              accountCode: account.code
          );
          await Setting().put('localAuthUserInfo', {
            'image': account.image,
            'fullName': account.fullName,
            'phone': account.phone,
            'email': account.email,
            'birthDate': account.birthDate,
            'code': account.code,
          });
        }
        return true;
      }else if(res is Map && res['status'] == 'FAIL'){
        showMessage(res['message'], type: 'fail');
      }
    }
    return false;
  }
  Future<bool> delete()async{
    if(await authBiometric()) {
      showLoading();
      final token = await AppSecureStorage().get(
        'loginToken',
        accountName: _storageName(account.code)
      );
      final res = await call('Core.User.DeviceToken.delete', params: {
        'token': token,
        'uniqueDeviceId': AppInfo.deviceId
      });
      disableLoading();
      if (res is Map && account.isLogin()) {
        await AppSecureStorage().delete(
          'loginToken',
          accountName: _storageName(account.code)
        );
        await AppSecureStorage().delete(_lastLoginUserCodeKey);
        await Setting().delete('localAuthUserInfo');
        _lastLoginUser = '';
        return true;
      }
    }
    return false;
  }

  Future<bool> toggle()async{
    if(!account.isLogin()){
      return false;
    }
    if(await checkRegistered(account.code)){
      return !(await delete());
    }
    return await register();
  }

  Future<bool> loginWithToken(String accountCode, [Function(Map response)? fallbackLoginFail])async{
    if(accountCode != _lastLoginUser){
      return false;
    }

    if(await authBiometric()) {
      showLoading();
      final token = await AppSecureStorage().get(
        'loginToken',
        accountName: _storageName(accountCode)
      );
      if (empty(AppInfo.deviceId) || empty(token) || account.isLogin()) {
        disableLoading();
        return false;
      }
      bool flag = true;
      int count = 0;
      dynamic res;
      while(flag && count < 3){
        res = await call<Map>('Core.User.DeviceToken.login', params: {
          'fields': {
            'username': accountCode,
            'token': token,
          },
          'uniqueDeviceId': AppInfo.deviceId
        });
        if(res == 'Required Login' ||
            (res is Map && res['status'] == 'FAIL'
                && res['message'] == 'Invalid token')
        ){
          count++;
          await Future.delayed(const Duration(seconds: 2));
        }else{
          flag = false;
        }
      }
      disableLoading();
      if (res is Map && res['status'] == 'SUCCESS' && !empty(res['account'])) {
        await account.login(res);
        if(!empty(res['loginToken'])){
          saveToken(res['loginToken'], accountCode: accountCode);
        }
        return true;
      }else{
        fallbackLoginFail?.call(res is Map ? res : {'status': 'FAIL'});
      }
    }
    return false;
  }

  Future<void> saveToken(String loginToken, {required String accountCode})async{
    if (!empty(_lastLoginUser)) {
      await AppSecureStorage().delete('loginToken',
          accountName: _storageName(_lastLoginUser)
      );
    }

    await _setLoginUser(accountCode);
    await AppSecureStorage().put('loginToken', loginToken,
        accountName: _storageName(accountCode)
    );
  }

  Future<bool> authBiometric() async {
    return false;
  }
  Future<void> init()async{
    _canCheck = await canCheckBiometrics;
    await _getLastLoginUser();
    _enabled = true;
    if(account.isLogin() && !empty(_lastLoginUser)){
      await Setting().put('localAuthUserInfo', {
        'image': account.image,
        'fullName': account.fullName,
        'phone': account.phone,
        'email': account.email,
        'birthDate': account.birthDate,
        'code': account.code,
      });
    }
  }

  String _storageName(String accountCode){
    return _encryption('${AppInfo.rootAppDomain}/a/$accountCode');
  }
  String getAuth(){
    return '';
  }
  Future<void> clearOldUser()async{
    final oldUserCode = await AppSecureStorage().get(_lastLoginUserCodeKey);
    if(!empty(oldUserCode)) {
      _lastLoginUser = '';
      await AppSecureStorage().delete(_lastLoginUserCodeKey);
      await AppSecureStorage().delete('loginToken',
          accountName: _storageName(oldUserCode!)
      );
      await Setting().delete('localAuthUserInfo');
    }
  }
}

enum AuthType {
  /// Face authentication.
  face,

  /// Fingerprint authentication.
  fingerprint,

  /// Iris authentication.
  iris,

  /// Any biometric (e.g. fingerprint, iris, or face) on the device that the
  /// platform API considers to be strong. For example, on Android this
  /// corresponds to Class 3.
  strong,

  /// Any biometric (e.g. fingerprint, iris, or face) on the device that the
  /// platform API considers to be weak. For example, on Android this
  /// corresponds to Class 2.
  weak,
}