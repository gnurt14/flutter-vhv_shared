// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;

class Utils {
  static retryFuture(future, delay) {
    Future.delayed(Duration(milliseconds: delay), () {
      future();
    });
  }

  static Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('www.google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  static Future<List<PlatformFile>> compressImages(
      List<PlatformFile> imagesToCompress) async {
    List<PlatformFile> imagesCompressed = [];

    for (var element in imagesToCompress) {
      final mimeType = lookupMimeType(element.path ?? '');
      if (mimeType == null) continue;

      if (mimeType.contains("jpg") ||
          mimeType.contains("jpeg") ||
          mimeType.contains("png")) {
        final originalFile = File(element.path!);
        final bytes = await originalFile.readAsBytes();
        final image = img.decodeImage(bytes);
        if (image != null) {
          final compressedBytes = img.encodeJpg(image, quality: 80);
          final tempDir = Directory.systemTemp;
          final compressedPath =
          path.join(tempDir.path, 'compressed_${path.basename(element.path!)}');

          final compressedFile = await File(compressedPath).writeAsBytes(compressedBytes);

          imagesCompressed.add(PlatformFile(
            name: path.basename(compressedPath),
            size: compressedFile.lengthSync(),
            path: compressedPath,
          ));
        } else {
          imagesCompressed.add(element);
        }
      } else {
        imagesCompressed.add(element);
      }
    }

    return imagesCompressed;
  }
}
