// import 'package:flutter/material.dart';
// import 'base.dart';
// import 'popup_loading_utils.dart';
//
// class BaseBlocListener<B extends BlocBase<S>, S extends BaseState> extends StatelessWidget {
//   final Widget child;
//   final BlocWidgetListener<S> listener;
//   final B? bloc;
//   final BlocListenerCondition<S>? listenWhen;
//   final bool showLoadingPopup;
//   final bool handleNetworkError;
//   final bool Function(S state)? customShowLoadingCondition;
//
//   const BaseBlocListener({
//     super.key,
//     required this.child,
//     required this.listener,
//     this.bloc,
//     this.listenWhen,
//     this.showLoadingPopup = true,
//     this.handleNetworkError = true,
//     this.customShowLoadingCondition,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<B, S>(
//       bloc: bloc,
//       listenWhen: listenWhen,
//       listener: (context, state) {
//         final actionState = _getState(state);
//         //do some thing common
//         if (showLoadingPopup) {
//           //handle show/close loading popup
//           final needShow = customShowLoadingCondition?.call(state) ?? (actionState is LoadingState);
//           if (needShow) {
//             PopupLoadingUtils.of(context).show();
//           } else {
//             PopupLoadingUtils.of(context).close();
//           }
//         }
//         //
//         listener(context, state);
//       },
//       child: child,
//     );
//   }
//
//   BaseState _getState(BaseState state) {
//     if (_checkHasActionState(state)) {
//       return (state as dynamic).actionState;
//     }
//     return state;
//   }
//
//   bool _checkHasActionState(BaseState state) {
//     var result = false;
//     try {
//       (state as dynamic).actionState;
//       result = true;
//     } catch (_) {}
//     return result;
//   }
// }
