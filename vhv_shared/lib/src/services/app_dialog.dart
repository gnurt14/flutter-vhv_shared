// import 'package:bot_toast/bot_toast.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:vhv_shared/generated/l10n.dart';
// import 'package:vhv_shared/src/global.dart';
// import 'package:vhv_shared/src/widgets/base_button.dart';
//
// class AppDialog {
//   AppDialog._();
//   static AppDialog? _instance;
//   factory AppDialog() {
//     _instance ??= AppDialog._();
//     return _instance!;
//   }
//
//   void showDialogConfirm({
//     required String title,
//     required String message,
//     required VoidCallback onConfirm,
//     VoidCallback? onCancel,
//     String? confirmText,
//     String? cancelText,
//   }) {
//     BotToast.showCustomText(
//       backgroundColor: Colors.black.withValues(alpha: 0.1),
//       duration: const Duration(days: 365),
//       toastBuilder: (cancelFunc) => AlertDialog(
//         title: Text(title),
//         content: Text(message),
//         actionsAlignment: MainAxisAlignment.spaceBetween,
//         actions: [
//           BaseButton.outlined(
//             onPressed: () {
//               cancelFunc();
//               if (onCancel != null) onCancel();
//             },
//             child: Text(cancelText ?? VHVSharedStrings.of(globalContext).cancel),
//           ),
//           BaseButton(
//             onPressed: () {
//               cancelFunc();
//               onConfirm();
//             },
//             child: Text(confirmText ?? VHVSharedStrings.of(globalContext).accept),
//           ),
//         ],
//       ),
//     );
//   }
// }
