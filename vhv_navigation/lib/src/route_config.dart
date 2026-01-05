// import 'package:flutter/widgets.dart';
// import 'package:go_router/go_router.dart';
//
// /// Mô tả một route có thể mở rộng
// class RouteDefinition {
//   final String path;
//   final Widget Function(BuildContext, GoRouterState) builder;
//   final List<RouteDefinition> subRoutes;
//
//   RouteDefinition({
//     required this.path,
//     required this.builder,
//     this.subRoutes = const [],
//   });
//
//   /// Chuyển `RouteDefinition` thành `GoRoute`
//   GoRoute toGoRoute() {
//     return GoRoute(
//       path: path,
//       builder: builder,
//       routes: subRoutes.map((sub) => sub.toGoRoute()).toList(),
//     );
//   }
// }
