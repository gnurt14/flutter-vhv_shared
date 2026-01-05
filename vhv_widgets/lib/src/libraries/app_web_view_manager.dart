import 'dart:io' hide Cookie;
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' as flutter_inappwebview;


import 'package:vhv_widgets/src/import.dart';

class AppWebViewManager{
  AppWebViewManager._();
  static AppWebViewManager? _instance;
  factory AppWebViewManager(){
    _instance ??= AppWebViewManager._();
    return _instance!;
  }
  flutter_inappwebview.CookieManager get cookieManager
  => flutter_inappwebview.CookieManager.instance();

  Future<bool> loginWebView([String? domain])async{
    if(!kIsWeb && (Platform.isIOS || Platform.isAndroid) && account.isLogin()) {
      List<Cookie> cookies = await AppCookieManager().getCookies(domain);
      for (var element in cookies) {
        if (element.name == 'AUTH_BEARER_default') {
          return await cookieManager.setCookie(
            url: flutter_inappwebview.WebUri.uri(Uri.parse(domain ?? AppInfo.domain)),
            name: element.name,
            value: element.value
          );
        }
      }
    }
    return false;
  }
  Future<flutter_inappwebview.Cookie?> getCookie({
    String name = 'AUTH_BEARER_default',
    String? domain,
    flutter_inappwebview.InAppWebViewController? webViewController
  })async{
    if(!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      return await cookieManager.getCookie(
        url: flutter_inappwebview.WebUri.uri(Uri.parse(domain??AppInfo.domain)),
        name: name,
        webViewController: webViewController
      );
    }
    return null;
  }
  Future<void> logoutWebView({String? domain,})async{
    if(!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await cookieManager.deleteAllCookies();
    }
  }

  void setCookie(Cookie element){
    cookieManager.setCookie(
        url: flutter_inappwebview.WebUri.uri(Uri.parse(AppInfo.domain)),
        name: element.name,
        value: element.value
    );
  }
}