import 'package:image_picker/image_picker.dart';
import 'package:vhv_widgets/vhv_widgets.dart';
import 'package:vhv_widgets/src/wechat_asset_picker/constants/picker_method.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:flutter/material.dart';

class AppMediaPicker{
  AppMediaPicker._();
  static AppMediaPicker? _instance;
  factory AppMediaPicker(){
    _instance ??= AppMediaPicker._();
    return _instance!;
  }
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickImage({
    bool hasUpload = true
  })async{
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    return await _xFileUpload<String>(pickedFile?.path, hasUpload: hasUpload);
  }

  Future<String?> pickVideo({
    bool hasUpload = true
  })async{
    final XFile? pickedFile = await _picker.pickVideo(
      source: ImageSource.gallery,
    );
    return await _xFileUpload<String>(pickedFile?.path, hasUpload: hasUpload);
  }

  Future<String?> recordVideo({
    bool hasUpload = true
  })async{
    final XFile? pickedFile = await _picker.pickVideo(
      source: ImageSource.camera,
    );
    return await _xFileUpload<String>(pickedFile?.path, hasUpload: hasUpload);
  }

  Future<String?> takeImage({
    bool hasUpload = true
  })async{
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
    );
    return await _xFileUpload<String>(pickedFile?.path, hasUpload: hasUpload);
  }

  Future<String?> camera(BuildContext context, {
    bool hasUpload = true
  })async{
    final res = await AppPermissions().requestPhoto();
    if(!context.mounted){
      return null;
    }
    if(res) {
      final res = await PickMethod.camera(
          maxAssetsCount: 1,
          requestType: RequestType.image,
          handleResult: (BuildContext context, AssetEntity result) =>
              Navigator.of(context).pop(<AssetEntity>[result])
      ).method(context, []);
      if(res != null && res.isNotEmpty){
        final file = await res.first.file;
        if(file != null) {
          return await _xFileUpload<String>(
              file.path, hasUpload: hasUpload);
        }
      }
    }
    return null;
  }


  Future<String?> pickFile({
    bool hasUpload = true,
    List<String>? allowedExtensions,
    FileType? type
  })async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: allowedExtensions != null ? FileType.custom : (type ?? FileType.any),
      allowedExtensions: allowedExtensions
    );
    return await _xFileUpload<String>(result?.files.single.path, hasUpload: hasUpload);
  }

  Future<List<String>?> pickFiles({
    bool hasUpload = true,
    List<String>? allowedExtensions,
    FileType? type
  })async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: allowedExtensions != null ? FileType.custom : (type ?? FileType.any),
        allowedExtensions: allowedExtensions
    );
    return await _xFileUpload<List<String>>(result?.files.where((e) => e.path != null).map((e){
      return e.path!;
    }).toList(), hasUpload: hasUpload);
  }


  Future<T?> _xFileUpload<T extends Object>(T? path, {bool hasUpload = true})async{
    if(path is String){
      if(hasUpload){
        showLoading();
        final resUpload = await upload(path);
        disableLoading();
        if(resUpload is Map && !empty(resUpload['path'])){
          return resUpload['path'];
        }else{
          return null;
        }
      }
      return path;
    }else if(path is List<String>){
      final res = await Future.wait<String?>(path.map((e) => _xFileUpload<String>(e, hasUpload: hasUpload)));
      return res.whereType<String>().toList() as T;
    }
    return null;
  }
}
