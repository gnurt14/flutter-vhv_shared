import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:vhv_navigation/vhv_navigation.dart';
import 'package:vhv_shared/vhv_shared.dart';
Function(String screen)? logScreenView;
const double _defaultScrollControlDisabledMaxHeightRatio = 9.0 / 16.0;
typedef GoToMenuFunction = Function(Map params, {Future<bool> Function(Map params)? extraProcess, bool popAll});
class NavigatorService extends InheritedWidget {

  static late NavigatorService instance;

  NavigatorService({super.key, required super.child}) {
    instance = this;
  }
  static NavigatorService of(BuildContext context) {
    final NavigatorService? result = context.dependOnInheritedWidgetOfExactType<NavigatorService>();
    assert(result != null, 'No NavigationService found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(NavigatorService oldWidget) => false;

  NavigatorState get navigator => navigatorGlobalKey.currentState!;
  GoRouter get _goRouter{
    try{
      return GoRouter.of(navigatorGlobalKey.currentContext!);
    }catch(e){
      rethrow;
    }
  }
  GoRouter _goRouterWithContext(BuildContext context) => GoRouter.of(context);

  Uri? get currentUri{
    if(AppRouter.mounted){
      return _goRouter.state.uri;
    }
    return null;
  }

  GoRouterState? get currentState{
    if(AppRouter.mounted){
      return _goRouter.state;
    }
    return null;
  }

  bool isDeclaredPath(String path) {
    if(AppRouter.mounted) {
      bool check(List<RouteBase> routes) {
        for (final route in routes) {
          if (route is GoRoute) {
            if (route.path == path) {
              return true;
            }
          }

          if (route is ShellRoute || (route is GoRoute && route.routes.isNotEmpty)) {
            if (check(route.routes)) return true;
          }
        }
        return false;
      }

      return check(_goRouter.configuration.routes);
    }
    return false;
  }

  bool hasRouter(String location){
    if(AppRouter.mounted){
      return _goRouter.configuration.findMatch(Uri.parse(location)).isNotEmpty;
    }else{
      return false;
    }
  }

  void go(String location, {Object? extra, Map<String, String>? queryParameters}){
    if(AppRouter.mounted){
      final routerFix = queryParameters != null ? Uri.parse(fixRouter(location)).replace(
          queryParameters: queryParameters
      ).toString() : fixRouter(location);
      _goRouter.go(routerFix, extra: getArguments(fixRouter(location), extra));
    }else{
      pushNamedAndRemoveAllUntil(location);
    }
  }

  void goNamed(String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
    String? fragment,
  }){
    if(AppRouter.mounted) {
      _goRouter.goNamed(name,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
          extra: extra,
          fragment: fragment
      );
    }
  }

  bool get isHome => !navigator.canPop();

  FutureOr<void> pop<T extends Object?>([T? result]) {
    if(kDebugMode){
      logger.d('AppNavigator pop at \n${getStackTrace('package:vhv_navigation/src/navigator_service.dart')??''}',
          stackTrace: StackTrace.empty);
    }
    try{
      if(AppRouter.mounted && _goRouter.canPop()){
        try{
          _goRouter.pop<T>(result);
        }catch(_){
          if (navigator.canPop()) {
            navigator.pop<T>(result);
          }
        }
      }else if (navigator.canPop()) {
        navigator.pop<T>(result);
      }
    }catch(e, stack){
      FlutterError.reportError(FlutterErrorDetails(
        exception: e,
        library: 'vhv_navigation',
        stack: stack,
        context: ErrorDescription('Lỗi appNavigator.pop'),
      ));
    }
  }
  
  void popTo(String router){
    return navigator.popUntil((route) => route.settings.name == fixRouter(router) || route.isFirst);
  }
  void goToHome([BuildContext? context]){
    if(kDebugMode){
      logger.d('AppNavigator to /\n${getStackTrace('package:vhv_navigation/src/navigator_service.dart')??''}',
          stackTrace: StackTrace.empty);
    }
    if(AppRouter.mounted) {
      return (context != null ? _goRouterWithContext(context) : _goRouter).go('/');
    }
    pushNamedAndRemoveAllUntil('/');

  }
  Future<Object?> homePushNamedTo(String router, {dynamic arguments, Map<String, String>? queryParameters}){
    router = fixRouter(router);
    sendAnalyticsCurrentScreen(router);
    if(kDebugMode){
      logger.d('AppNavigator to $router\n${getStackTrace('package:vhv_navigation/src/navigator_service.dart')??''}',
          stackTrace: StackTrace.empty);
    }
    if(AppRouter.mounted){
      final routerFix = queryParameters != null ? Uri.parse(router).replace(
          queryParameters: queryParameters
      ).toString() : router;
      if(AppRouter.isTopRouter(router)){
        go(routerFix, extra: getArguments(router, arguments));
        return Future.value(null);
      }
      go('/');
      return _goRouter.push(routerFix, extra: getArguments(router, arguments));
    }
    return navigator.pushNamedAndRemoveUntil(router, (Route<dynamic> route) => route.isFirst, arguments: arguments);
  }

  bool canPop(BuildContext context){
    if(AppRouter.mounted){
      return GoRouter.of(context).canPop();
    }
    return Navigator.canPop(context);
  }

  bool _isSameRoute(String a, String b) {
    return false;
    // Uri uriA = Uri.parse(a);
    // Uri uriB = Uri.parse(b);
    // return uriA.path == uriB.path && uriA.queryParameters == uriB.queryParameters;
  }
  Future<dynamic> pushNamed(String router, {dynamic arguments, String? screenName, Map<String, String>? queryParameters}){
    router = fixRouter(router);
    sendAnalyticsCurrentScreen(screenName ?? router);
    if(kDebugMode){
      logger.d('AppNavigator to $router\n'
          '${arguments != null ? 'with params: $arguments\n' : ''}'
          '${getStackTrace('package:vhv_navigation/src/navigator_service.dart')??''}',
          stackTrace: StackTrace.empty);
    }
    if(AppRouter.mounted){
      final routerFix = queryParameters != null ? Uri.parse(router).replace(
        queryParameters: queryParameters
      ).toString() : router;
      if(AppRouter.isTopRouter(router)){
        go(routerFix, extra: getArguments(router, arguments));
        return Future.value(null);
      }
      final currentLocation = _goRouter.state.uri;
      if(router == '/Social/Chat' || router == '/Chat'){
        if((currentLocation.toString() == '/Social/Chat' || currentLocation.toString() == '/Chat')){
          if(arguments is Map && _goRouter.state.extra is Map && arguments['roomId'] == (_goRouter.state.extra as Map)['roomId']) {
            return Future.value(null);
          }else{
            pop();
          }
        }
      }

      if(_isSameRoute(currentLocation.toString(), router)){
        return Future.value(null);
      }
      return _goRouter.push(routerFix, extra: getArguments(router, arguments));
    }

    return navigator.pushNamed(router, arguments: getArguments(router, arguments));
  }
  Future<dynamic> pushNamedAndRemoveAllUntil(String router, {dynamic arguments, String? screenName,
    Map<String, String>? queryParameters})async{
    router = fixRouter(router);
    sendAnalyticsCurrentScreen(screenName ?? router);
    if(kDebugMode){
      logger.d('AppNavigator to $router\n${getStackTrace('package:vhv_navigation/src/navigator_service.dart')??''}',
          stackTrace: StackTrace.empty);
    }
    if(AppRouter.mounted){
      final routerFix = queryParameters != null ? Uri.parse(router).replace(
          queryParameters: queryParameters
      ).toString() : router;
      if(AppRouter.isTopRouter(router)){
        go(routerFix, extra: getArguments(router, arguments));
        return Future.value(null);
      }
      try{
        final currentLocation = _goRouter.state.uri;
        if(_isSameRoute(currentLocation.toString(), router)){
          return Future.value(null);
        }
      }catch(_){

      }
      return go(routerFix, extra: getArguments(router, arguments));
    }
    return await navigator.pushNamedAndRemoveUntil(router,
      (Route<dynamic> route) => false,
      arguments: getArguments(router, arguments)
    );
  }
  Future<dynamic> pushNamedAndRemoveUntil(String router, {dynamic arguments, String? screenName,
    Map<String, String>? queryParameters
  })async{
    router = fixRouter(router);
    sendAnalyticsCurrentScreen(screenName ?? router);
    if(kDebugMode){
      logger.d('AppNavigator to $router\n${getStackTrace('package:vhv_navigation/src/navigator_service.dart')??''}',
          stackTrace: StackTrace.empty);
    }
    final routerFix = queryParameters != null ? Uri.parse(router).replace(
        queryParameters: queryParameters
    ).toString() : router;
    if(AppRouter.mounted){
      if(AppRouter.isTopRouter(router)){
        return go(routerFix, extra: getArguments(router, arguments));
      }
      final currentLocation = _goRouter.state.uri;
      if(_isSameRoute(currentLocation.toString(), router)){
        return Future.value(null);
      }
      return _goRouter.pushReplacement(router, extra: getArguments(router, arguments));
    }
    return navigator.popAndPushNamed(router, arguments: getArguments(router, arguments));
  }

  Future<dynamic> pushAndRemoveAllUntil(dynamic router, {String? screenName}) async{
    assert (router is Widget || router is Widget Function());
    sendAnalyticsCurrentScreen(screenName ?? router.toString());
    if(kDebugMode){
      logger.d('AppNavigator to $router\n${getStackTrace('package:vhv_navigation/src/navigator_service.dart')??''}',
          stackTrace: StackTrace.empty);
    }
    return navigator.pushAndRemoveUntil(MaterialPageRoute(
        builder: (_) => router is Widget ? router : router()
      ),
      (Route<dynamic> route) => false
    );
  }
  Future<dynamic> pushAndRemoveUntil(dynamic router, {String? screenName}){
    assert (router is Widget || router is Widget Function());
    sendAnalyticsCurrentScreen(screenName ?? router.toString());
    if(kDebugMode){
      logger.d('AppNavigator to $router\n${getStackTrace('package:vhv_navigation/src/navigator_service.dart')??''}',
          stackTrace: StackTrace.empty);
    }
    return navigator.pushReplacement(MaterialPageRoute(
        builder: (_) => router is Widget ? router : router())
    );
  }

  Future<dynamic> push(dynamic router, {String? screenName}) async{
    assert (router is Widget || router is Widget Function());
    sendAnalyticsCurrentScreen(screenName ?? router.toString());
    if(kDebugMode){
      logger.d('AppNavigator to $router\n${getStackTrace('package:vhv_navigation/src/navigator_service.dart')??''}',
          stackTrace: StackTrace.empty);
    }
    return navigator.push(MaterialPageRoute(builder: (_) => router is Widget ? router : router()));
  }

  void sendAnalyticsCurrentScreen(String? router){
    if(router != null && router.isNotEmpty){
      logScreenView?.call(router);
    }
  }

  @protected
  String fixRouter(String router){
    if(factories['router'] is Map && factories['router'].containsKey(router)){
      if(kDebugMode){

        logger.d('AppNavigator to ${factories['router'][router]}\n${getStackTrace('package:vhv_navigation/src/navigator_service.dart')??''}',
            stackTrace: StackTrace.empty);
      }
      return factories['router'][router];
    }
    return router;
  }

  Future<dynamic> showFullDialog({
    bool barrierDismissible = false,
    required Widget child,
    PopInvokedWithResultCallback? onPopInvokedWithResult,
    bool canPop = true,
    BuildContext? context,
  })async{
    return dialog(
      barrierDismissible: barrierDismissible,
      useSafeArea: false,
      context: context,
      child: PopScope(
        canPop: canPop,
        onPopInvokedWithResult: onPopInvokedWithResult,
        child: Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide.none,
          ),
          elevation: 0,
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: child,
          ),
        ),
      )
    );
  }

  Future<T?> showBottomSheet<T>({
    required Widget child,
    Color? backgroundColor,
    String? barrierLabel,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    BoxConstraints? constraints,
    Color? barrierColor,
    bool isScrollControlled = false,
    double scrollControlDisabledMaxHeightRatio = _defaultScrollControlDisabledMaxHeightRatio,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    bool? showDragHandle,
    bool useSafeArea = false,
    RouteSettings? routeSettings,
    AnimationController? transitionAnimationController,
    Offset? anchorPoint,
    AnimationStyle? sheetAnimationStyle,
  }) {
    return showModalBottomSheet<T>(
      context: globalContext,
      builder: (context) => child,
      backgroundColor: backgroundColor,
      barrierLabel: barrierLabel,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      constraints: constraints,
      barrierColor: barrierColor,
      isScrollControlled: true,
      scrollControlDisabledMaxHeightRatio: scrollControlDisabledMaxHeightRatio,
      useRootNavigator: useRootNavigator,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      showDragHandle: showDragHandle,
      useSafeArea: useSafeArea,
      routeSettings: routeSettings,
      transitionAnimationController: transitionAnimationController,
      anchorPoint: anchorPoint,
      sheetAnimationStyle: sheetAnimationStyle
    );
  }

  Future<T?> dialog<T>({
    required Widget child,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
    TraversalEdgeBehavior? traversalEdgeBehavior,
    BuildContext? context
  }) {
    try{
      return material.showDialog<T>(
        context: context ?? globalContext,
        builder: (context) => child,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
        barrierLabel: barrierLabel,
        useSafeArea: useSafeArea,
        useRootNavigator: useRootNavigator,
        routeSettings: routeSettings,
        anchorPoint: anchorPoint,
        traversalEdgeBehavior: traversalEdgeBehavior
      );
    }catch(e){
      logger.e(e);
      return Future.value(null);
    }
  }
  @protected
  dynamic getArguments(String routeName, [dynamic arguments]){
    if(arguments is Map){
      return arguments;
    }
    if(arguments != null){
      return arguments;
    }
    return {};
  }

}
