import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vhv_network/vhv_network.dart' as dio;
import 'package:vhv_storage/vhv_storage.dart';
import 'package:vhv_widgets/src/libraries/app_web_view_manager.dart';
import 'package:vhv_widgets/vhv_widgets.dart';
import 'dart:io';
import 'package:wechat_assets_picker/wechat_assets_picker.dart' hide LatLng;
export 'package:wechat_assets_picker/wechat_assets_picker.dart'
    show AssetEntity;
export 'package:file_picker/file_picker.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:ui' as ui;
import 'views/image_cache.dart';

part 'helpers/media.dart';
part 'helpers/system.dart';
part 'helpers/web_view.dart';
part 'helpers/enum.dart';
part 'helpers/typedef.dart';

Future<T?> showCustomDialog<T>({
  required BuildContext context,
  required Widget child,
  bool barrierDismissible = true,
  Color? barrierColor,
  bool useSafeArea = true,
  Object? arguments,
}) {
  return showDialog<T>(
    context: context,
    useSafeArea: useSafeArea,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor ?? Colors.black54,
    builder: (BuildContext dialogContext) {
      return Center(
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          elevation: 0,
          child: child,
        ),
      );
    },
  );
}

// Future showPopup({
//   bool barrierDismissible = true,
//   OnWillPop? onWillPop,
//   String? title,
//   String? image,
//   String? titleConfirm,
//   Function()? onPressConfirm,
//   Function()? onPressCancel,
//   String? titleCancel,
//   String? content,
//   TypeButtonPopup? typeButton,
//   bool? hideCancel,
//   TypeIconPopup? typeIcon,
//   TypeImagePopup? typeImage,
// }) async {
//   return await Get.dialog(
//     PopScope(
//       canPop: (onWillPop == null),
//       onPopInvoked: (didPop) async {
//         if (onWillPop != null) {
//           final backNavigationAllowed = await onWillPop();
//           if (backNavigationAllowed) {
//             appNavigator.pop();
//           } else {}
//         }
//       },
//       child: Popup(
//         title: title,
//         content: content,
//         image: image,
//         titleConfirm: titleConfirm,
//         titleCancel: titleCancel,
//         onPressConfirm: onPressConfirm,
//         onPressCancel: onPressCancel,
//         typeIcon: typeIcon,
//         typeButton: typeButton ?? TypeButtonPopup.vertical,
//         hideCancel: hideCancel ?? false,
//         typeImage: typeImage,
//       ),
//     ),
//     barrierDismissible: barrierDismissible,
//   );
// }

