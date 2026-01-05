// import 'package:flutter/material.dart';
// import 'base.dart';
//
// class BaseBlocConsumer<B extends BlocBase<S>, S extends BaseState> extends StatelessWidget {
//   final Widget? child;
//   final BlocWidgetListener<S> listener;
//   final Widget Function(BuildContext context, S state, Widget? child) builder;
//   final B? bloc;
//   final BlocListenerCondition<S>? listenWhen;
//   final BlocBuilderCondition<S>? buildWhen;
//   final bool showLoadingPopup;
//   final bool handleNetworkError;
//   final bool Function(S state)? customShowLoadingCondition;
//
//   const BaseBlocConsumer({
//     super.key,
//     this.child,
//     required this.listener,
//     required this.builder,
//     this.bloc,
//     this.listenWhen,
//     this.buildWhen,
//     this.showLoadingPopup = true,
//     this.handleNetworkError = true,
//     this.customShowLoadingCondition,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return BaseBlocListener<B, S>(
//       listener: listener,
//       listenWhen: listenWhen,
//       showLoadingPopup: showLoadingPopup,
//       handleNetworkError: handleNetworkError,
//       customShowLoadingCondition: customShowLoadingCondition,
//       bloc: bloc,
//       child: BlocBuilder<B, S>(
//         buildWhen: buildWhen,
//         bloc: bloc,
//         builder: (context, state) {
//           return builder(context, state, child);
//         },
//       ),
//     );
//   }
// }
