part of '../helper.dart';

// class CommonPageRoute<T> extends PageRoute<T> with MaterialRouteTransitionMixin<T> {
//   CommonPageRoute({
//     required this.builder,
//     this.isDefault = false,
//     super.settings,
//     this.maintainState = true,
//     super.fullscreenDialog,
//     super.allowSnapshotting = true,
//   }) {
//     assert(opaque);
//   }
//
//   final WidgetBuilder builder;
//   final bool isDefault;
//
//   @override
//   Widget buildContent(BuildContext context) => builder(context);
//
//   @override
//   final bool maintainState;
//
//   @override
//   String get debugLabel => '${super.debugLabel}(${settings.name})';
// }