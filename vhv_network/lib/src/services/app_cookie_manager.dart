import 'dart:async';
import 'dart:convert';
export 'dart:io' show Cookie;
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' as flutter_inappwebview;
import 'package:cookie_jar/cookie_jar.dart';
import 'package:vhv_network/src/cookie_jar/web.dart';
import 'package:vhv_network/src/cookie_jar/web_storage.dart';
import 'package:vhv_network/vhv_network.dart';
import 'package:vhv_shared/vhv_shared.dart';
import 'package:vhv_storage/vhv_storage.dart';

import '../dio_adapter/custom_cookie_manager.dart';
export 'package:dio_cookie_manager/dio_cookie_manager.dart' show CookieManager;

class AppCookieManager{
  AppCookieManager._();
  static AppCookieManager? _instance;
  factory AppCookieManager(){
    _instance ??= AppCookieManager._();
    return _instance!;
  }
  set dio(Dio dio){
    _dio = dio;
  }
  Dio? _dio;
  CookieJar? get cookieJar => _cookieJar;
  CookieJar? _cookieJar;
  CustomCookieManager? get cookieManager => (cookieJar != null
      ? CustomCookieManager(cookieJar!) : null);

  bool get isCookieSupport => true;
  void init(Function(CookieJar cookieJar) onSuccess){
    if(isCookieSupport) {
      if(!kIsWeb) {
        if (appDocumentDirectory == null) {
          getApplicationSupportDirectory().then((res) {
            _cookieJar = CustomPersistCookieJar(
                ignoreExpires: true,
                storage: FileStorage('${res.path}/.cookies/')
            );
            onSuccess(_cookieJar!);
          });
        } else {
          _cookieJar ??= CustomPersistCookieJar(
              ignoreExpires: true,
              storage: FileStorage('${appDocumentDirectory!.path}/.cookies/')
          );
          onSuccess(_cookieJar!);
        }
      }else{
        _cookieJar ??= CustomPersistCookieJar(
          ignoreExpires: true,
          storage: WebCookieStorage()
        );
        onSuccess(_cookieJar!);
      }

    }
  }

  Future<List<Cookie>> getCookies([String? domain])async{
    if(isCookieSupport && _cookieJar != null){
      try{
        return await _cookieJar!.loadForRequest(Uri.parse('${domain ?? VHVNetwork.domain}/'));
      }catch(e){
        logger.e(e);
        return <Cookie>[];
      }
    }
    return <Cookie>[];
  }
  Future<void> setCookie(String key, String value)async{
    if(_cookieJar != null){
      setCookies([Cookie(key, value)]);
    }
  }
  Future<void> setCookies(List<Cookie> cookies, [String? domain])async{
    if(_dio != null && cookieJar != null) {
      if (cookies.isNotEmpty) {
        cookies.removeWhere((element) => element.name != 'AUTH_BEARER_default');
        await cookieJar!.saveFromResponse(Uri.parse(domain ?? VHVNetwork.domain), cookies);
      }
      if (_dio!.interceptors.isNotEmpty) {
        _dio!.interceptors.removeWhere((element) => element is CookieManager);
      }
      _dio!.interceptors.add(CookieManager(cookieJar!));
    }
  }
  Future<void> setExtraCookies(String domain, List<Cookie> cookies)async{
    if(_dio != null && cookieJar != null) {
      if (cookies.isNotEmpty) {
        await cookieJar!.saveFromResponse(Uri.parse(domain), cookies);
      }
      _dio!.interceptors.add(CookieManager(cookieJar!));
      await getCsrfToken(domain);
    }
  }


  Future<bool> deleteAllCookies()async{
    if(cookieJar != null){
      cookieJar!.deleteAll();
    }
    if(!(kIsWeb || isDesktop)) {
      flutter_inappwebview.CookieManager cookieManager = flutter_inappwebview.CookieManager.instance();
      return await cookieManager.deleteAllCookies();
    }
    return false;
  }

  Future<void> deleteAppCookie()async{
    if(cookieJar != null) {
      await cookieJar!.delete(Uri.parse('${VHVNetwork.domain}/'));
    }
    if(!(kIsWeb || isDesktop)) {
      flutter_inappwebview.CookieManager cookieManager = flutter_inappwebview.CookieManager.instance();
      await cookieManager.deleteAllCookies();
    }
  }
  Map decodeAuthBearer(Cookie cookie){
    if (cookie.name == 'AUTH_BEARER_default') {
      List d = cookie.value.split('.');
      if(d.length > 1) {
        String data = jsonDecode(utf8.decode(base64
            .decode(base64.normalize(d[1]))))['data'];
        if (data.isNotEmpty) {
          return { for (var e in data.split(';')) e.split('|').first: (e.split('|').length > 1 ? e.split('|').last : '')};
        }
      }
    }
    return {};
  }

  final Map _csrfToken = {};
  void clearCsrfToken(){
    _csrfToken.clear();
  }
  String csrfToken([String? url]){
    // if(VHVNetwork.isTesting){
    //   return '21350a9a33a7d1736b2aa9a7925905d3ac768e224bc1933e56b7c30ecbbeab58';
    // }

    if(url == null){
      final uri = Uri.parse(VHVNetwork.domain);
      return _csrfToken[uri.host] ?? '';
    }else{
      final uri = Uri.parse(url);
      return _csrfToken[uri.host] ?? '';
    }
  }

  FutureOr<String> getCsrfToken(String domain, [bool force = false])async{
    final key = Uri.parse(domain).host;
    func()async{
        List<Cookie> results = await getCookies(domain);
        for (var element in results) {
          if (element.name == 'AUTH_BEARER_default') {
            List d = element.value.split('.');
            if(d.length > 1) {
              String data = jsonDecode(utf8.decode(base64
                  .decode(base64.normalize(d[1]))))['data'];

              if (data.isNotEmpty) {
                data.split(';').forEach((element) {
                  if (element.split('|')[0] == 'csrfToken') {
                    String csrfToken = element.substring(element.indexOf('"'));
                    csrfToken = csrfToken.substring(1, csrfToken.length - 1);
                    _csrfToken.addAll({
                      key: csrfToken
                    });
                  }
                });
              }
            }
          }
          if (element.name == 'be') {
            debugPrint('Server: ${element.value}');
          }
        }
    }
    if(_csrfToken.containsKey(key) && !empty(_csrfToken[key]) && !force){
      func();
    }else{
      await func();
    }
    return _csrfToken[key] ?? (checkType<Map>(Setting().get('site'))?['csrfToken']) ?? '';
  }
  Future<bool> hasLogin([String? domain])async{
    if(kIsWeb){
      return true;
    }
    final cookies = await getCookies(domain);
    final bearers = cookies.where((cookie) => cookie.name == 'AUTH_BEARER_default');
    if(bearers.isNotEmpty){
      final bearer = bearers.first;
      final data = decodeAuthBearer(bearer);
      return !empty(data['userId']);
    }
    return false;
  }
  Future<void> clearData()async{
    _csrfToken.clear();
    if(isCookieSupport && _cookieJar != null){
      await _cookieJar!.deleteAll();
    }
    if(!(kIsWeb || isDesktop)) {
      flutter_inappwebview.CookieManager cookieManager = flutter_inappwebview.CookieManager.instance();
      await cookieManager.deleteAllCookies()  ;
    }
  }
}