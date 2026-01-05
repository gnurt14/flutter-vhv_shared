import 'dart:convert';
import 'dart:io';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:vhv_shared/vhv_shared.dart';
import 'package:vhv_storage/vhv_storage.dart';


Future<String?> saveBase64File(String imageBase64, {
  required String fileName,
  Uint8List? saveData,
  required Function(String fileName) onSuccess
})async{
  String? savePath;
  Uint8List? data;
  if(saveData == null) {
    try {
      data = base64Decode(imageBase64);
    } catch (e) {
      if (!imageBase64.endsWith('=')) {
        imageBase64 = '$imageBase64=';
      }
      data = base64Decode(imageBase64);
    }
  }else{
    data = saveData;
  }

  try {
    final res = await VHVStorage.requestStoragePermission();
    if (res) {
      final filePath = await VHVStorage.getFilePath(fileName);
      String saveFileName = '';
      if (filePath != '') {
        final file = File(filePath);
        bool fileExists = await file.exists();
        if (fileExists) {
          String directory = file.parent.path;
          String baseName = file.uri.pathSegments.last
              .split('.')
              .first;
          String extension = file.uri.pathSegments.last
              .split('.')
              .last;
          int counter = 1;
          String newFilePath = '$directory/$baseName ($counter).$extension';
          File newFile = File(newFilePath);
          while (await newFile.exists()) {
            counter++;
            newFilePath = '$directory/$baseName ($counter).$extension';
            newFile = File(newFilePath);
          }
          await newFile.writeAsBytes(data);
          saveFileName =
              newFile.path.substring(newFile.path.lastIndexOf('/') + 1);
          onSuccess(saveFileName);
        } else {
          await file.writeAsBytes(data);
          saveFileName = file.path.substring(file.path.lastIndexOf('/') + 1);
          onSuccess(saveFileName);
        }
        return savePath;
      }
    }
  }catch(_){
    return await saveFileAs(
      fileName: fileName,
      data: data,
      onSuccess: onSuccess
    );
  }
  return null;
}

Future<String?> saveFileAs({
  required String fileName,
  required Uint8List data,
  required Function(String path) onSuccess
})async{
  MimeType? mimeType;
  final ext = fileName.substring(fileName.lastIndexOf('.') + 1);
  switch(ext){
    case 'pdf':
      mimeType = MimeType.pdf;
      break;
    case 'jpg':
    case 'jpeg':
      mimeType = MimeType.jpeg;
      break;
    case 'png':
      mimeType = MimeType.png;
      break;
    case 'gif':
      mimeType = MimeType.gif;
      break;
    case 'zip':
      mimeType = MimeType.zip;
      break;
    case 'rar':
      mimeType = MimeType.rar;
      break;
    case 'mp3':
      mimeType = MimeType.mp3;
      break;
    case 'mp4':
      mimeType = MimeType.mp4Video;
      break;
  }
  String? fileSave;
  if(mimeType != null && (!kIsWeb && (Platform.isIOS || Platform.isAndroid))){
    fileSave = await FileSaver.instance.saveAs(
        name: fileName.substring(0, fileName.indexOf('.')),
        bytes: data,
        fileExtension: ext,
        mimeType: mimeType
    );
  }else{
    fileSave = await FileSaver.instance.saveFile(
      name: fileName.substring(0, fileName.indexOf('.')),
      bytes: data,
      fileExtension: ext
    );
  }
  if(!empty(fileSave)) {
    onSuccess(fileSave ?? '');
    return fileSave;
  }
  return null;
}