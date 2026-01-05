import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PageRouter{
  const PageRouter({
    this.redirect,
    required this.builder,
    required this.pages
  });
  final ShellRouteBuilder? builder;
  final List<PageRouterInfo> pages;
  final GoRouterRedirect? redirect;

  ShellRoute get router{
    return ShellRoute(
      builder: builder,
      redirect: redirect,
      routes: [
        ...pages.map((e){
          return GoRoute(
            path: e.path,
            redirect: e.redirect,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              name: state.uri.path,
              child: e.builder(context, state),
              transitionDuration: Duration.zero,
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        })
      ],
    );
  }

  Map<String, String> get pageInfos => <String, String>{for(PageRouterInfo page in pages)page.path: page.title};
}

class PageRouterInfo{
  final Widget Function(BuildContext context, GoRouterState state) builder;
  final String path;
  final String title;
  final GoRouterRedirect? redirect;

  PageRouterInfo({this.redirect, required this.builder, required this.path, required this.title});
}