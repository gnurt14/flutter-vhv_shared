// import 'package:flutter/material.dart';
//
// class PopupLoadingUtils {
//   static bool isShowing = false;
//   BuildContext context;
//
//   PopupLoadingUtils.of(this.context);
//
//   void show({bool canDismiss = false, Widget? subWidget}) async {
//     if (isShowing) return;
//     isShowing = true;
//     try {
//       await showDialog(
//         barrierDismissible: canDismiss,
//         context: context,
//         builder: (context) {
//           return WillPopScope(
//             onWillPop: () async => canDismiss,
//             child: _LoadingHub(subWidget: subWidget),
//           );
//         },
//       );
//     } catch (_) {}
//     isShowing = false;
//   }
//
//   void close() {
//     if (isShowing) {
//       isShowing = false;
//       Navigator.of(context).pop();
//     }
//   }
// }
//
// class _LoadingHub extends StatelessWidget {
//   final Widget? subWidget;
//
//   const _LoadingHub({this.subWidget});
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       content: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const CircularProgressIndicator(
//             valueColor: AlwaysStoppedAnimation<Color>(Color(0xffFF671F)),
//             strokeWidth: 2.0,
//           ),
//           if (subWidget != null) subWidget!,
//         ],
//       ),
//     );
//   }
// }
