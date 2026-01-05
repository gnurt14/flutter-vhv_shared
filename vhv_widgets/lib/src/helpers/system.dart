part of '../helper.dart';
Future<List<CameraDescription>> initCamera()async{
  List<CameraDescription> cameras = [];
  if(isAndroid || isIOS){
    try {
      await availableCameras().then((camera) {
        cameras = camera;
      }).catchError((_) {
      });
    } on CameraException catch (_) {
    }
  }
  return cameras;
}


T getResponsive<T>({
  T? phone,
  T? largePhone,
  T? tablet,
  T? smallTablet,
  T? largeTablet,
  T? laptop,
  T? desktop,
}) {
  T? value;
  if (tablet != null) {
    smallTablet ??= tablet;
    largeTablet ??= tablet;
  }
  tablet = null;
  const list = <String>[
    'phone',
    'largePhone',
    'tablet',
    'smallTablet',
    'largeTablet',
    'laptop',
    'desktop'
  ];
  Map<String, T> device = {};
  for (var element in list) {
    switch (element) {
      case 'phone':
        if (phone != null) {
          device['phone'] = phone;
        }
        break;
      case 'largePhone':
        if (largePhone != null) {
          device['largePhone'] = largePhone;
        }
        break;
      case 'tablet':
        if (tablet != null) {
          device['tablet'] = tablet;
        }
        break;
      case 'smallTablet':
        if (smallTablet != null) {
          device['smallTablet'] = smallTablet;
        }
        break;
      case 'largeTablet':
        if (largeTablet != null) {
          device['largeTablet'] = largeTablet;
        }
        break;
      case 'laptop':
        if (laptop != null) {
          device['laptop'] = laptop;
        }
        break;
      case 'desktop':
        if (desktop != null) {
          device['desktop'] = desktop;
        }
        break;
    }
  }
  for (var element in list.reversed) {
    final DeviceSize size = DeviceType.getSize(element);
    final min = size.minWidth ?? 0;
    final max = size.maxWidth ?? double.infinity;

    if (globalContext.width >= min && max >= globalContext.width) {
      if (device[element] != null) {
        return device[element] as T;
      }
    } else if (globalContext.width < min) {
      device.remove(element);
      // if (device[element] != null) {
      //   value = device[element];
      // }
    }
  }
  value = device.values.last;
  return value as T;
}

bool get isLocal {
  return (AppInfo.domain.contains('192.168.1.130') ||
      AppInfo.domain.toString().endsWith('coquan.vn'));
}

String htmlDecode(dynamic html) {
  if (html != null) {
    return HtmlUnescape().convert(html.toString()..replaceAll('&nbsp;', ' '));
  }
  return '';
}

String convertSimpleTag(String text, [bool remove = false]) {
  return text.replaceAllMapped(RegExp(r'\[\[(/)?([biu])\]\]'), (e) {
    return '<${e.group(1) ?? ''}${e.group(2)}>';
  });
}

String noTag(String? text, [bool tag = true]) {
  if (text == null) {
    return '';
  }
  String t = '';
  if (tag) {
    t = convertSimpleTag(text.replaceAll('&', '&amp;').replaceAll('<', '&lt;'));
  } else {
    t = text.replaceAll('&', '&amp;').replaceAll('<', '&lt;');
  }
  return t.replaceAllMapped(RegExp(r'\[\[(/?b|/?u|/?i)\]\]'), (match) {
    return '<${match.group(1)}>';
  });
}

String quote(dynamic html) {
  if (html is String) {
    if (empty(html)) {
      return '';
    }
    return htmlDecode(noTag(convertSimpleTag(html))
        .replaceAll('''
    ''', r'\n')
        .replaceAll('\n', r'\n')
        .replaceAll('\r', '')
        .replaceAll('\'', r'&#39;')
        .replaceAll('"', r'&quot;'));
  }
  if (html is num) {
    return html.toString();
  }
  return '';
}

Future<void> callTo(String phone) async {
  if (await canLaunchUrl(Uri.parse('tel:$phone'))) {
    await launchUrl(Uri.parse('tel:$phone'));
  } else {
    throw 'Could not tel to $phone';
  }
}

Future<void> smsTo(String phone) async {
  if (await canLaunchUrl(Uri.parse('sms:$phone'))) {
    await launchUrl(Uri.parse('sms:$phone'));
  } else {
    throw 'Could not send sms to $phone';
  }
}

Future<void> mailTo(String email, [String? subject]) async {
  final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': subject ?? ''});
  launchUrl(emailLaunchUri);
}

Future showFullModal({
  bool barrierDismissible = true,
  required Widget child,
  OnWillPop? onWillPop,
}) async {
  return await appNavigator.showFullDialog(
    child: SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: child,
    ),
    barrierDismissible: barrierDismissible, // us
  );
}

Future showModal(
    {String? title,
      TextStyle? titleStyle,
      Widget? content,
      String? middleText,
      Widget? cancel,
      List<Widget>? actions,
      VoidCallback? onCancel,
      VoidCallback? onCustom,
      VoidCallback? onConfirm,
      Color? confirmTextColor,
      Color? confirmColor,
      Color? backgroundColor,
      String? textConfirm,
      String? textCancel,
      String? textCustom,
      bool barrierDismissible = true,
      double radius = 10.0,
      double elevation = 10.0,
      PopInvokedWithResultCallback? onPopInvokedWithResult,
      bool canPop = true,
      EdgeInsets? insetPadding,
      EdgeInsets? contentPadding,
      bool showCloseButton = false,
      DialogSize dialogSize = DialogSize.auto}) async {
  double width = double.infinity;
  if (dialogSize == DialogSize.small) {
    width = 500.0;
  }
  if (dialogSize == DialogSize.medium) {
    width = 800.0;
  }
  if (dialogSize == DialogSize.large) {
    width = 1140.0;
  }
  return await appNavigator.dialog(
    child: PopScope(
      canPop: canPop,
      onPopInvokedWithResult: onPopInvokedWithResult,
      child: Dialog(
          elevation: elevation,
          insetPadding: insetPadding ?? const EdgeInsets.all(20),
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius:
            factories['dialogRadius'] ?? BorderRadius.circular(radius),
          ),
          child: Container(
            constraints: BoxConstraints(maxWidth: width),
            width: width,
            child: Builder(builder: (context) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: contentPadding ?? const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (showCloseButton)
                          const SizedBox(
                            height: 20,
                          ),
                        if (!empty(title))
                          Text(title!,
                              textAlign: TextAlign.center,
                              style: titleStyle ??
                                  Theme.of(globalContext)
                                      .textTheme
                                      .titleLarge),
                        if (!empty(title)) const SizedBox(height: 20),
                        Flexible(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (middleText != null)
                                    HTMLViewer(
                                      middleText,
                                      style: {
                                        '*': Style(textAlign: TextAlign.center)
                                      },
                                    ),
                                  if (content != null) content,
                                  if (!empty(onConfirm) ||
                                      !empty(onCancel) ||
                                      !empty(onCustom) ||
                                      !empty(actions))
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: [
                                          if (!empty(onCancel))
                                            BaseButton.outlined(
                                              onPressed: () {
                                                onCancel!();
                                                appNavigator.pop();
                                              },
                                              style: OutlinedButton.styleFrom(
                                                  side: BorderSide(
                                                      color: Theme.of(context)
                                                          .primaryColor),
                                                  foregroundColor: Theme.of(context)
                                                      .primaryColor),
                                              child:
                                              Text(lang(textCancel ?? 'Huỷ')),
                                            ),
                                          if (!empty(onConfirm) && !empty(onCancel))
                                            const SizedBox(width: 20),
                                          if (!empty(onConfirm))
                                            BaseButton(
                                              onPressed: onConfirm,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: confirmColor ??
                                                    Theme.of(context).primaryColor,
                                                foregroundColor: confirmTextColor ??
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary,
                                              ),
                                              child: Text(
                                                  lang(textConfirm ?? 'Đồng ý')),
                                            ),
                                          ...actions ?? []
                                        ],
                                      ),
                                    )
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                  if (showCloseButton)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Opacity(
                          opacity: 0.6,
                          child: Icon(ViIcons.x_close),
                        ),
                        onPressed: () async {
                          appNavigator.pop();
                        },
                      ),
                    )
                ],
              );
            }),
          )),
    ),
    barrierDismissible: barrierDismissible,
  );
}

Future<dynamic> showBottomMenu({
  required Widget child,
  Widget? bottom,
  dynamic title,
  Widget? actionRight,
  Widget? actionLeft,
  // BottomSheetType? type,
  Color? backgroundColor,
  EdgeInsets? padding,
  BorderRadiusGeometry? borderRadius,
  bool isDismissible = true,
  bool isScrollControlled = true,
  bool enableDrag = true,
  bool ignoreSafeArea = false,
}) async {
  assert(title == null || title is String || title is Widget);
  final res = await AppBottomSheets().showCustom(
    ignoreSafeArea: ignoreSafeArea,
    child: CustomBottomSheetMenu(
      bottom: bottom,
      title: title,
      actionRight: actionRight,
      actionLeft: actionLeft,
      backgroundColor: backgroundColor,
      padding: padding,
      // type: type,
      borderRadius: borderRadius,
      child: child,
    ),
    isDismissible: isDismissible,
    isScrollControlled: isScrollControlled,
    enableDrag: enableDrag,
    backgroundColor: Colors.transparent
  );
  return res;
}

Future<void> openFile(String file,
    {String? title,
      TextStyle? styleTitle,
      bool notDownload = false,
      bool isLocalFile = false,
      bool downloadImage = false}) async {
  await appNavigator.pushNamed('/ViewFile',
      arguments: {
        'file': file,
        'title': title,
        'styleTitle': styleTitle,
        'isLocalFile': isLocalFile,
        'downloadImage': downloadImage ? 1 : null,
        'hasDownloadFile': (notDownload) ? false : !empty(factories['hasDownloadFile'])
      });
}



Future<String> getAssetFilePath(AssetEntity? asset) async {
  if (asset is AssetEntity) {
    final File? file = await asset.file;
    return file is File ? file.path : '';
  }
  return '';
}

Future<File?> getAssetFile(AssetEntity? asset) async {
  if (asset is AssetEntity) {
    return await asset.file;
  }
  return null;
}



Future downloadForWebView(String url, [bool setLogin = true]) async {
  if (setLogin) {
    await AppWebViewManager().loginWebView();
  }
  return await appNavigator.dialog(
    child: BaseDialog(canPop: false, child: WebViewDownload(url)),
    barrierDismissible: false,
  );
}

