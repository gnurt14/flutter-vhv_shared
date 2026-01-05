import 'package:vhv_core/vhv_core.dart';

Future<String> getDownloadDir(String fileName, {bool toDownloadFolder = true,
  @Deprecated('Remove on new core')
  String? saveName}){
  return VHVStorage.getFilePath(saveName ?? fileName, toDownloadFolder);
}