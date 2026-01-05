library;

import 'dart:async';
import 'dart:io';

import 'package:downloadsfolder/downloadsfolder.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;


import 'package:vhv_storage/vhv_storage.dart';
import 'package:vhv_shared/vhv_shared.dart';
export 'src/app_storage.dart';
export 'src/app_secure_storage.dart';

export 'src/helper.dart';

export 'src/hive_type_ids.dart';

class VHVStorage{
  VHVStorage._();

  static FutureOr<void> init({
    String? folderDownload,
    List<String>? boxes
  })async{
    _folderDownloadName = folderDownload;
    Setting.appStorage = AppStorage();
    await Setting.init(['Config', 'CacheData', ...?boxes]);
  }

  static String? _folderDownloadName;
  static String? get folderDownloadName => _folderDownloadName;

  static void setDownloadFolderName(String folderDownloadName){
    _folderDownloadName = folderDownloadName;
  }

  static Future<String> getFilePath(String url, [toDownloadFolder = true,
    bool override = false])async{
    String fileName = url.contains('/') ? url.substring(url.lastIndexOf('/') + 1) : url;
    String? savePath;
    Directory? downloadDirectory;
    if(!kIsWeb) {
      if(toDownloadFolder){
        try{
          downloadDirectory = downloadDirectory ?? await getDownloadDirectory();
        }catch(_){
          downloadDirectory = downloadDirectory ?? await getApplicationDocumentsDirectory();
        }
        if(Platform.isAndroid) {
          if(VHVStorage.folderDownloadName == null){
            VHVStorage.setDownloadFolderName((await PackageInfo.fromPlatform()).packageName);
          }
          final folderApp = Directory('${downloadDirectory.path}/${VHVStorage.folderDownloadName}');
          if (!await folderApp.exists()) {
            await folderApp.create();
          }
          return await getUniqueFilePath('${folderApp.path}/$fileName', override);
        }else{
          return await getUniqueFilePath('${downloadDirectory.path}/$fileName', override);
        }
      }else{
        downloadDirectory = downloadDirectory ?? await getApplicationDocumentsDirectory();
        return await getUniqueFilePath('${downloadDirectory.path}/$fileName', override);
      }
    }
    return await getUniqueFilePath(savePath??'', override);
  }
  static Future<bool> requestStoragePermission() async {
    if(!kIsWeb && Platform.isAndroid){
      if (DeviceService.sdkInt >= 33) {
        return true;
      } else {
        PermissionStatus status = await Permission.storage.request();
        return status.isGranted;
      }
    }else{
      return true;
    }
  }
  static Future<String> getUniqueFilePath(String originalPath, [bool override = false]) async {
    if(override){
      return originalPath;
    }
    String dir = p.dirname(originalPath);
    String basename = p.basenameWithoutExtension(originalPath);
    String extension = p.extension(originalPath);

    String newPath = originalPath;
    int count = 1;

    while (await File(newPath).exists()) {
      newPath = p.join(dir, '$basename($count)$extension');
      count++;
    }

    return newPath;
  }

}
