import 'package:flutter/material.dart';
import 'package:vhv_config/vhv_config.dart';
import 'package:vhv_navigation/vhv_navigation.dart';
import 'package:vhv_shared/vhv_shared.dart';

class VHVRouter{
  VHVRouter._();
  static void copyWith({
    GoToMenuFunction? forceToMenu,
    Route<dynamic>? Function(RouteSettings settings)? generateRoute,
  }){
    _forceToMenu = forceToMenu ?? _forceToMenu;
    _generateRoute = generateRoute ?? _generateRoute;
  }
  static Route<dynamic>? Function(RouteSettings settings)? _generateRoute;
  static GoToMenuFunction? _forceToMenu;
  static Uri? _getLink(Map params, {
    required VoidCallback afterLoginCallback,
    VoidCallback? fallback
  }){
    String link = '';
    if(params['appLink'] is String && !empty(params['appLink'])){
      link = params['appLink'];
      if(RegExp(r'^([a-zA-Z0-9]+.)+([a-zA-Z0-9]+)$').hasMatch(link)){
        link = (Uri.parse('${AppInfo.domain}/?page=${link}').replace(
          queryParameters: <String, String>{
            'page': link,
            ...params['params'] is Map ? Map<String, String>.fromIterable((params['params'] as Map).entries,
                key: (e) => e.key.toString(),
                value: (e) => e.value.toString()
            ) : {},

          }
        )).toString();
      }
    } else if(params['link'] is String && !empty(params['link'])){
      link = params['link'];
    }else if(empty(params['link']) && !empty(params['page'])){
      link = '${AppInfo.domain}/?page=${params['page']}';
    }
    if(!empty(link)) {
      final url = linkToUri(link);
      final queryParameters = url.queryParameters;
      if (!empty(queryParameters['requiredLogin']) && !account.isLogin()) {
        checkLoginFunction(afterLoginCallback);
        return null;
      } else {
        if(appNavigator.isDeclaredPath(uriToPath(url))) {
          return url;
        }else{
          fallback?.call();
        }
      }
    }else{
      fallback?.call();
    }
    return null;
  }
  static Future<dynamic> pushTo(Map params, {
    VoidCallback? fallback
  }){
    final link = _getLink(params,
      afterLoginCallback: () => pushTo(params),
      fallback: fallback
    );
    if(!empty(link)) {
      return appNavigator.pushNamed(uriToPath(link!), arguments: link.queryParameters);
    }
    return Future.value(null);
  }
  static void goTo(Map params, {
    VoidCallback? fallback
  }){
    final link = _getLink(params,
      afterLoginCallback: () => goTo(params),
      fallback: fallback
    );
    if(!empty(link)) {
      appNavigator.go(uriToPath(link!), extra: link.queryParameters);
    }
  }

  static Future<dynamic> goToMenu(Map params, {
    Future<bool> Function(Map params)? extraProcess,
    bool force = true,
    bool popAll = true,
  })async{
    if(_forceToMenu != null && force){
      return await _forceToMenu!(params, extraProcess: extraProcess, popAll: popAll);
    }

    if (params['link'] == AppInfo.domain || params['link'] == '${AppInfo.domain}/'
        || params['link'].toString().toLowerCase() == '${AppInfo.domain}/page/home') {
      goToHome();
      return;
    }
    if (params['link'] is String) {
      final link = Uri.parse(params['link']);
      if (empty(params['title']) && link.queryParameters.containsKey('title')) {
        params['title'] = link.queryParameters['title'];
      }
      if (params['link'].startsWith('/page/') ||
          params['link'].startsWith('page/')
          || params['link'].startsWith('/pageCode/') ||
          params['link'].startsWith('pageCode/')) {
        params['link'] = '${AppInfo.domain}${params['link'].startsWith('/')
            ? ''
            : '/'}${params['link']}';
      }
    }
    if(extraProcess != null){
      final res = await extraProcess(params);
      if(!res){
        return false;
      }
    }
    if (!empty(params['requiredLogin']) && !account.isLogin()) {
      checkLoginFunction(() => goToMenu(params, popAll: popAll, force: force));
      return true;
    }
    if(!appNavigator.isHome && empty(params['notGoToHome']) && popAll){
      goToHome();
      await Future.delayed(const Duration(milliseconds: 300));
    }

    if(empty(params['link']) && !empty(params['page'])){
      params['link'] = '${AppInfo.domain}/?page=${params['page']}';
    }
    final res = await linkToRouter(params['link']??'', generateRoute: _generateRoute, notRouter: true);
    if(res != false && res != '/' && res != '/Start'){
      await linkToRouter(params['link'], generateRoute: _generateRoute);
    }else if(!empty(params['page']) && !params['page'].toString().contains('/')){
      final res = linkToRouter('${AppInfo.domain}/?page=${params['page']??''}',
          generateRoute: _generateRoute,
          notRouter: true);
      if(res != false && res != '/' && res != '/Start'){
        await linkToRouter('${AppInfo.domain}/?page=${params['page']??''}',
            generateRoute: _generateRoute
        );
      }
    }
  }
  static Uri linkToUri(String link){
    if (!empty(link)) {
      if(link.contains('/page/')
          && (link.startsWith('http') || RegExp(r'\/[0-9a-zA-Z-_]+\/page\/').hasMatch(link))){
        link = 'https://appdomain.com${link.substring(link.indexOf('/page/'))}';
      }else{
        final reg = RegExp(r'/([a-zA-Z0-9-_]+)(/page/[a-zA-Z0-9-_]+)');
        if(reg.hasMatch(link)){
          final data = reg.firstMatch(link);
          link = data?.group(2) ?? link;
        }
      }
      if(link.startsWith('/page/') || link.startsWith('/?page=')){
        link = 'https://appdomain.com$link';
      }else if(link.startsWith('page/') || link.startsWith('?page=')){
        link = 'https://appdomain.com/$link';
      }
      if(!link.contains('?') && link.contains('&')){
        link = link.replaceFirst('&', '?');
      }
      final Uri url = Uri.parse(link);
      String? page;
      String? id;
      if(url.pathSegments.length > 1 && url.pathSegments.first == 'page'){
        final checkForHexRegExp = RegExp(r'^[0-9a-fA-F]{24}$');
        if(checkForHexRegExp.hasMatch(url.pathSegments.last)){
          id = url.pathSegments.last;
        }
        page = (url.pathSegments.sublist(1, (id != null)?url.pathSegments.length - 1:url.pathSegments.length)).join('.');
      }else{
        page = url.queryParameters['page'];
      }
      Map params = {};
      if(!empty(id)){
        params.addAll({
          'id': id
        });
      }
      if (!empty(page)) {
        params.addAll(url.queryParameters);
        params.remove('page');
      } else if (url.pathSegments.isNotEmpty
          && (url.pathSegments[0].toString().contains('/u/') || url.pathSegments[0].toString().contains('/g/'))) {
        page = url.pathSegments[0];
        params['id'] = url.pathSegments[1];
      }
      if (page != null) {
        final router = pageConvert(page);
        if(!empty(router)){
          return Uri.parse(AppInfo.domain).replace(
            path: '/page$router',
            queryParameters: Map<String, dynamic>.from(params)
          );
        }
      }
    }
    return Uri.parse(AppInfo.domain);
  }
  static RouteSettings? linkGetRouter(String link){
    final uri = linkToUri(link);
    if (!empty(uriToPath(uri))) {
      return RouteSettings(name: uriToPath(uri), arguments: uri.queryParameters);
    }
    return null;
  }

  static String uriToPath(Uri uri){
    if (!empty(uri.path) && uri.path.startsWith('/page/')) {
      final paths = uri.pathSegments.sublist(1);
      if(paths.last == 'list'){
        paths.removeLast();
      }
      return '/${paths.join('/')}';
    }
    return '';
  }

  static bool _isRouteExist(String path, List<RouteBase> routes) {
    for (final route in routes) {
      if (route is GoRoute && route.path == path) {
        return true;
      } else if (route is ShellRoute) {
        if (_isRouteExist(path, route.routes)) {
          return true;
        }
      }
    }
    return false;
  }

  static bool hasRouter(RouteSettings? router, {RouteFactory? generateRoute, List<RouteBase>? routes}){
    if(router != null && routes != null) {
      return _isRouteExist(router.name ?? '', routes);
    }else if(router != null && generateRoute != null) {
      final a = generateRoute(router);
      if (!(a == null || (a is CommonPageRoute && a.isDefault))) {
        return true;
      }
    }
    return false;
  }
  static dynamic linkToRouter(String link, {bool notRouter = false,
    RouteFactory? generateRoute,
    List<RouteBase>? routes
  }){
    /// Longnd fix
    ///
    ///
    if (!empty(link)) {
      final router = linkGetRouter(link);
      if (router != null) {
        final params = checkType<Map>(router.arguments)??{};
        final router0 = router.name??'';
        if(!notRouter){
          if(generateRoute != null || routes != null){
            if(hasRouter(router, generateRoute: generateRoute, routes: routes)){
              if(!empty(params['requiredLogin'])){
                checkLoginFunction(()async{
                  appNavigator.pushNamed(router0, arguments: params);
                });
              } else {
                appNavigator.pushNamed(router0, arguments: params);
              }
            }else{
              return false;
            }
          }else{
            if(!empty(params['requiredLogin'])){
              checkLoginFunction(()async{
                appNavigator.pushNamed(router0, arguments: params);
              });
            } else {
              appNavigator.pushNamed(router0, arguments: params);
            }
          }
          return true;
        }else {
          return router.name;
        }
      }
    }
    return false;
  }
  static String pageConvert(String? page) {
    if(factories['routerConvert'] != null)return factories['routerConvert'](page);
    if(page == null || page.indexOf('http') == 0){
      return '';
    }
    if (page != '') {
      List<String> pages = page.split('.');
      if (pages.first == 'Mobile') {
        pages.removeAt(0);
      }
      if (pages.last == 'list') {
        pages.removeLast();
      } else {
        final String last =
            pages.last[0].toUpperCase() + pages.last.substring(1);
        pages.removeLast();
        pages.add(last);
      }
      pages = pages.map((e){
        return e[0].toUpperCase() + e.substring(1);
      }).toList();
      return '/${pages.join('/')}';
    }
    return '';
  }
  static bool isHomeLink(String? link){
    if(link != null) {
      return [AppInfo.domain, '${AppInfo.domain}/', '${AppInfo.domain}/home',
        '${AppInfo.domain}/page/start', '${AppInfo.domain}/page/home',
        '/page/start', 'page/start',
        '/page/home', 'page/home',
        '/'
      ].contains(link.toLowerCase());
    }
    return false;
  }
  static Future<bool> checkLinkOnRouter(Map params)async{
    if(empty(params['link'])){
      return false;
    }
    final res = linkToRouter(params['link'], generateRoute: _generateRoute, notRouter: true);
    return !(res == false);
  }
}