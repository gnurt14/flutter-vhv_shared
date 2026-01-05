import 'package:flutter/material.dart';
import 'package:vhv_navigation/vhv_navigation.dart';
import 'package:vhv_shared/vhv_shared.dart';
import 'widgets/no_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter/foundation.dart';
class AppRouter{
  AppRouter._();
  static void init({
    String initialLocation = '/',
    List<NavigatorObserver>? observers,
    GoRouterRedirect? redirect,
    required List<RouteBase> routes,
    GoRouterWidgetBuilder? errorBuilder,
    List<String>? topRoutes,
    ApplicationStateNotifier? refreshListenable,
    List<String>? notCheckLoginRoutes,
    GoExceptionHandler? onException,
  }){
    if (kIsWeb) {
      // Import bên trong if để tránh lỗi Android/iOS
      setUrlStrategy(PathUrlStrategy());
    }
    _onException = onException;
    _notCheckLoginRoutes = notCheckLoginRoutes ?? [];
    _initialLocation = initialLocation;
    _observers = observers;
    _redirect = redirect;
    _customRoutes = routes;
    _errorBuilder = errorBuilder;
    _refreshListenable = refreshListenable;
    if(topRoutes != null && topRoutes.isNotEmpty) {
      _topRoutes = topRoutes;
    }
  }
  static GoExceptionHandler? _onException;
  static List<String> _notCheckLoginRoutes = [];
  static String _initialLocation = '/';
  static List<NavigatorObserver>? _observers;
  static GoRouterRedirect? _redirect;
  static GoRouterWidgetBuilder? _errorBuilder;
  static late final List<RouteBase> _customRoutes;
  static List<String> _topRoutes = ['/'];

  static ApplicationStateNotifier? _refreshListenable;
  
  static bool get mounted => _mounted;
  static bool _mounted = false;

  static bool isTopRouter(String router) => _topRoutes.contains(router);
  static GoRouter? _goRouter;
  static GoRouter get router {
    _mounted = true;
    _goRouter ??= GoRouter(
        navigatorKey: navigatorGlobalKey,
        initialLocation: _initialLocation,
        routes: _customRoutes,
        refreshListenable: _refreshListenable ?? ApplicationStateNotifier(),
        // debugLogDiagnostics: true,
        observers: [
          BotToastNavigatorObserver(),
          MyNavigatorObserver(),
          ...?_observers
        ],
        onException: _onException,
        redirect: (context, state){
          if(account.isNeedVerify && state.uri.path != '/Login/Verify'){
            return '/Login/Verify';
          }
          if(account.isPasswordChangeRequired && state.uri.path != '/Account/ChangePassword'){
            return '/Account/ChangePassword';
          }
          if(account.authHandler.requiredLogin && !account.isLogin(context)){
            if(
            ///Khai báo các trang không cần check login
            _notCheckLoginRoutes.contains(state.uri.path)
                ///Các trang không cần check login
                || [
              '/Account/ForgotPassword',
              '/Forbidden',
              '/ViewFile',
              '/AppNotFound',
              '/OnBoarding',
            ].contains(state.uri.path)
                ///Các trang bắt đầu bằng chuỗi dưới sẽ k check login
                || [
              '/Account/Login',
              '/Login',
              '/Account/Register',
              '/Register',
              '/Guest',
            ].where((e) => state.uri.path.startsWith(e)).isNotEmpty
            ){
              return _redirect?.call(context, state);
            }
            return account.authHandler.loginRouter;
          }
          return _redirect?.call(context, state);
        },
        errorBuilder: _onException != null ? null : _errorBuilder ?? (context, state){
          return NoRouter(state);
        }
    );
    return _goRouter!;
  }
}

