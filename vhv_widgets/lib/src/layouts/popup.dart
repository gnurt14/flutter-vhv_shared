// import 'package:flutter/material.dart';
// import 'package:vhv_widgets/vhv_widgets.dart';
//
// class Popup extends StatelessWidget {
//   final String? title;
//   final Widget? Function()? titleBuild;
//   final String? content;
//   final Widget? Function()? contentBuild;
//   final String? image;
//   final Widget? Function()? imageBuild;
//   final String? titleConfirm;
//   final Function()? onPressConfirm;
//   final Function()? onPressCancel;
//   final String? titleCancel;
//
//   final TypeButtonPopup typeButton;
//   final bool hideCancel;
//   final TypeIconPopup? typeIcon;
//   final TypeImagePopup? typeImage;
//   const Popup({
//     super.key,
//     this.title,
//     this.content,
//     this.typeButton = TypeButtonPopup.vertical,
//     this.hideCancel = false,
//     this.titleConfirm,
//     this.titleCancel,
//     this.typeIcon,
//     this.typeImage,
//     this.image,
//     this.onPressConfirm,
//     this.onPressCancel,
//     this.titleBuild,
//     this.contentBuild,
//     this.imageBuild,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Theme.of(context).cardColor,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Stack(
//         alignment: Alignment.topLeft,
//         children: [
//           Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               if (typeImage != TypeImagePopup.large) ...[
//                 const SizedBox(height: 52),
//               ],
//               if (!empty(imageBuild)) ...[
//                 titleBuild!.call()!
//               ] else if (!empty(typeImage) && !empty(image)) ...[
//                 Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.vertical(
//                           top: Radius.circular(
//                               typeImage == TypeImagePopup.large ? 12 : 0)),
//                       child: ImageViewer(
//                         image,
//                         height: typeImage == TypeImagePopup.large ? 180 : 128,
//                         width: typeImage == TypeImagePopup.large
//                             ? double.infinity
//                             : typeImage == TypeImagePopup.medium
//                                 ? 160
//                                 : 128,
//                         fit: BoxFit.fitWidth,
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                   ],
//                 ),
//               ],
//               Flexible(
//                 fit: FlexFit.loose,
//                 child: ListView(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   shrinkWrap: true,
//                   children: [
//                     if (!empty(typeIcon)) ...[
//                       Align(
//                         alignment: Alignment.center,
//                         child: Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(60),
//                             color: typeIcon == TypeIconPopup.success
//                                 ? const Color(0xffD1FADF)
//                                 : const Color(0xffFECDCA),
//                           ),
//                           child: Icon(
//                             typeIcon == TypeIconPopup.success
//                                 ? ViIcons.check_circle_broken
//                                 : ViIcons.x_large,
//                             size: 40,
//                             color: typeIcon == TypeIconPopup.success
//                                 ? const Color(0xff027A48)
//                                 : const Color(0xffD92D20),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 16)
//                     ],
//                     titleBuild?.call() ??
//                         Text(
//                           title ?? 'Title',
//                           style:
//                               AppTextStyles.textM.setFontWeight(FontWeight.bold),
//                           textAlign: TextAlign.center,
//                         ),
//                     const SizedBox(height: 8),
//                     contentBuild?.call() ??
//                         Text(
//                           content ?? 'Content',
//                           style: AppTextStyles.normal.setColor(
//                             const Color(0xff475467),
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Row(
//                       children: [
//                         if (!hideCancel &&
//                             typeButton == TypeButtonPopup.horizontal) ...[
//                           Expanded(
//                             child: BaseButton.outlined(
//                               onPressed:
//                                   onPressCancel ?? () => appNavigator.pop(),
//                               child: Text(titleCancel ?? 'Thoát'),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                         ],
//                         Expanded(
//                           child: BaseButton(
//                             onPressed: () {
//                               onPressConfirm?.call();
//                             },
//                             child: Text(titleConfirm ?? 'Xác nhận'),
//                           ),
//                         ),
//                       ],
//                     ),
//                     if (!hideCancel &&
//                         typeButton == TypeButtonPopup.vertical) ...[
//                       const SizedBox(height: 8),
//                       BaseButton.outlined(
//                         onPressed: onPressCancel ?? () => appNavigator.pop(),
//                         child: Text(titleCancel ?? 'Thoát'),
//                       ),
//                     ],
//                   ],
//                 ),
//               )
//             ],
//           ),
//           IconButton(
//             onPressed: () => appNavigator.pop(),
//             icon: const Icon(ViIcons.x_close),
//           ),
//         ],
//       ),
//     );
//   }
// }
