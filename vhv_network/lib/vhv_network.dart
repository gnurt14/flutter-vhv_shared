library;

export 'package:dio/dio.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:vhv_network/src/dio_client.dart';
import 'package:vhv_network/src/network_config.dart';
import 'package:vhv_shared/vhv_shared.dart';
export 'src/network_config.dart';
export 'src/extension.dart';
export 'src/services/app_cookie_manager.dart';
export 'src/services/package_info_service.dart';
export 'src/helper.dart';
export 'src/basic_app_connect.dart';
export 'package:package_info_plus/package_info_plus.dart';

class VHVNetwork {
  VHVNetwork._();
  static NetworkConfig config = NetworkConfig();

  static Future<void> init(
      Site site, List<Site> sites, Future Function() onFail) async {
    await config.init(site, sites, onFail);
  }

  static Future<void> Function({int? id, String? title}) get changeInfo =>
      config.changeInfo;
  static Future<void> Function(String domain, {int? id, String? title})
      get changeForceDomain => config.changeForceDomain;

  static FutureOr<void> Function() get clearUserDomain =>
      config.clearUserDomain;
  static FutureOr<void> Function() get clearForceDomain =>
      config.clearForceDomain;

  static String get domain => config.domain;
  static String get mediaDomain => config.mediaDomain;
  static int? get id => config.id;
  static String get title => config.title;

  static String? Function(String service)? setForceDomain;

  static String callAPIDomain(String service, [String? forceDomain]) {
    return forceDomain ?? setForceDomain?.call(service) ?? domain;

  }

  static bool useSiteId(String service) {
    return setForceDomain?.call(service) == null;
  }

  static String getAPI(String serviceName, {String? forceDomain}) {
    if (serviceName.startsWith('https://')) {
      return serviceName;
    }
    if (serviceName == 'qqupload.php') {
      return '${callAPIDomain(serviceName, forceDomain)}/qqupload.php';
    }
    return '${callAPIDomain(serviceName, forceDomain)}'
        '${!empty(serviceName) ? ('/api/${serviceName.replaceAll('.', '/')}') : ''}';
  }

  static String convertDataToUrl(Map map, [String? field]) {
    String url = '';
    map.forEach((k, value) {
      String key = '$k';
      if (field != null) {
        key = '$field[$key]';
      }
      if (value is Map) {
        url += convertDataToUrl(value, key);
      } else if (value is List) {
        url += _convertListToUrl(value, key);
      } else if (value is String || value is num) {
        url += '&$key=$value';
      }
    });
    return ((field == null && url.startsWith('&'))
        ? '?${url.substring(1)}'
        : url);
  }

  static String _convertListToUrl(List data, String key) {
    String url = '';
    data.asMap().forEach((index, value) {
      if (value is String || value is num) {
        url += '&$key[$index]=$value';
      } else if (value is List) {
        url += _convertListToUrl(value, '$key[$index]');
      } else if (value is Map) {
        url += convertDataToUrl(value, '$key[$index]');
      }
    });
    return url;
  }

  static String checkDomainValid(String? domain) {
    if (domain != null) {
      if ((domain.toString().startsWith('https://')) ||
          (domain.toString().startsWith('http://'))) {
        return domain;
      } else {
        return 'https://$domain';
      }
    }
    return '';
  }

  static void clearData() {
    clearUserDomain();
    DioClient().clearData();
  }

  static bool isServerError(Object? error){
    return (error is DioException &&
        error.type == DioExceptionType.badResponse &&
        error.response?.statusCode == 503 &&
        error.message?.contains(
            'Server error - the server failed to fulfil an apparently valid request') ==
            true);
  }
  static bool isCancel(Object? e){
    if(e is DioException && e.type == DioExceptionType.cancel){
      return true;
    }
    if(e is HttpException && e.message.contains('Connection reset by peer')){
      return true;
    }
    return false;
  }
  static bool isRedirect(Object? error){
    return error is DioException
        && error.type == DioExceptionType.badResponse && error.response?.statusCode == 302;
  }
  static String getLinkRedirect(Object? error){
    if(isRedirect(error)){
      if(error is DioException && error.type == DioExceptionType.badResponse){
        return error.response?.headers.value(HttpHeaders.locationHeader) ?? '';
      }
    }
    return '';
  }

  static bool isNetworkErrorConnect(Object? error){
    return error is DioException
        && error.type == DioExceptionType.connectionError;
  }

  static Dio get dio => DioClient().dio;

  static Future<String> getPublicIP([String? domain]) async {
    final response = await dio.get(domain ?? 'https://api.ipify.org');
    return checkType<String>(response.data) ?? '';
  }
  // static bool isSpecialCase(dynamic response){
  //   if(response is String){
  //     return ['LoginVerify', 'Require login'].contains(response);
  //   }
  //   if(response is Map){
  //     return ['expired'].contains(response['status'].toString());
  //   }
  //   return false;
  // }
  // static void handleSpecialCase(dynamic response){
  //   VHVShared().applicationControl(response);
  // }

  static bool handleSpecialResponse(Response response){
    void logout(){
      if(account.isLogin()) {
        account.logout(
            localLogout: true
        );
        try{
          if (factories['forceLogoutMessage'] != null) {
            factories['forceLogoutMessage']();
          }
        }catch(_){}
      }
    }
    if(response.data is String){
      if(response.data == 'Require login' || response.data == 'Required login'){
        logout();
        return true;
      }
      if(response.data == 'LoginVerify'){
        account.needVerify(true);
        return true;
      }
      if(response.realUri.toString().contains('${VHVNetwork.domain}/page/login')){
        logout();
        return true;
      }
      if(response.data.toString().startsWith('{') || response.data.toString().startsWith('[')) {
        try {
          final data = jsonDecode(response.data.toString());
          if (data is Map && data['status'] == 'expired') {
          }
          if (data is Map && data['status'] == 'FAIL' &&
              data['message'] == 'Require login') {
            logout();
            return true;
          }
        } catch (_) {}
      }
    }
    return false;
  }
}
