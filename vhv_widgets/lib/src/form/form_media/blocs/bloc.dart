import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vhv_state/vhv_state.dart';
import 'package:vhv_widgets/src/form/form_media/form_media.dart';
import 'package:vhv_widgets/src/wechat_asset_picker/constants/picker_method.dart';
import 'package:vhv_widgets/vhv_widgets.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'state.dart';
export 'state.dart';

class FormMediaBloc extends BaseCubit<FormMediaState>{
  FormMediaBloc({
    this.length = 1,
    this.pickType = PickType.camera,
    this.type = FormMediaType.image,
    this.requestType = RequestType.image,
    this.ext = const ['jpg','gif','png','jpeg','bmp', 'heic'],
    this.hasBase64 = false,
    this.hasUpload = true,
    this.sizeLimit = 5242880,
    this.factoryKeys = const {},
    this.value,
    required this.fileKey,
    required this.onChanged,
    Function(FormMediaBloc)? onInit
  }) : super(const FormMediaState()){
    onInit?.call(this);
    if(!empty(value)) {
      emit(state.copyWith(items: convertToValue(value)));
    }
  }
  void setInitialValue(dynamic value){
    if(!state.isUploading) {
      emit(state.copyWith(items: convertToValue(value)));
    }
  }
  Map<String, MediaItem> convertToValue(dynamic value){
    if(!empty(value)){
      if(value is String){
        final key = '$value-${DateTime.now().millisecondsSinceEpoch}';
        return <String, MediaItem>{
          key: MediaItem(
            key: key,
            link: value,
            title: value.toString().contains('/') ? value.toString().substring(value.toString().lastIndexOf('/') + 1) : value,
            sortOrder: '1'
          )
        };
      }else if(value is List || value is Map){
        final values = toList(value);
        int index = 1;
        if(values.isNotEmpty){
          if(values.first is String){
            return Map<String, MediaItem>.fromEntries(values.map<MapEntry<String, MediaItem>>((value){
              final key = '$value-${DateTime.now().millisecondsSinceEpoch}';
              return MapEntry(key, MediaItem(
                key: key,
                link: value,
                title: value.toString().contains('/') ? value.toString().substring(value.toString().lastIndexOf('/') + 1) : value,
                sortOrder: '${index++}'
              ));
            }).toList());
          }else if(values.first is Map){
            return Map<String, MediaItem>.fromEntries(values.map<MapEntry<String, MediaItem>>((value){
              final key = '${value[fileKey]}-${DateTime.now().millisecondsSinceEpoch}';
              return MapEntry(key, MediaItem(
                  key: key,
                  link: value[fileKey],
                  title: !empty(value['title']) ? value['title'] : value[fileKey].toString().substring(value[fileKey].toString().lastIndexOf('/') + 1),
                  size: checkType<int>(value['size']),
                  sortOrder: '${index++}'
              ));
            }).toList());
          }
        }
      }
    }
    return <String, MediaItem>{};
  }
  final int length;
  final PickType pickType;
  final FormMediaType type;
  final RequestType requestType;
  final List<String> ext;
  final bool hasBase64;
  final bool hasUpload;
  final int sizeLimit;
  final Map<String, String> factoryKeys;
  final Function(dynamic) onChanged;
  final String fileKey;
  final dynamic value;

  final Map _hasUploaded = {};
  List<AssetEntity> assets = [];


  bool get isMultiSelect => length > 1;

  Future<List<AssetEntity>> _selectAssets({
    int? max,
    required BuildContext context,
  }) async {
    assets.clear();
    List<AssetEntity>? result;
    if(pickType == PickType.storage) {
      final res = await AppPermissions().requestPhoto();
      if(!context.mounted){
        return [];
      }

      if(res) {
        result = await PickMethod.camera(
          maxAssetsCount: max ?? 1,
          requestType: requestType,
          handleResult: (BuildContext context, AssetEntity result) =>
              Navigator.of(context).pop(<AssetEntity>[result])
        ).method(context, assets);
      }
    }else if(pickType == PickType.camera){
      final res = await Permission.camera.request();
      if(!context.mounted){
        return [];
      }
      if(res.isGranted || res.isLimited || res.isProvisional) {
        final AssetEntity? pickResult = await CameraPicker.pickFromCamera(
            context,
            pickerConfig: CameraPickerConfig(
              textDelegate: cameraPickerTextDelegateFromLocale(currentLocale),
              enableRecording: false,
              shouldDeletePreviewFile: true,
            ),
            locale: currentLocale
        );
        if (empty(result) && pickResult != null) {
          result = <AssetEntity>[pickResult];
        }
      }
    }
    if (result != null) {
      return List<AssetEntity>.from(result);
    }
    return [];
  }



  Future<void> selectFiles({
    required BuildContext context,
  })async{
    final length = this.length - state.items.length;
    if(length < 1 && isMultiSelect){
      return;
    }

    if(type == FormMediaType.multiPicker || type == FormMediaType.multiPickers){
      bool hasImage = false;
      bool hasFile = false;
      bool hasVideo = false;
      for (var e in ext) {
        if('.$e'.isImageFileName){
          hasImage = true;
        }else if('.$e'.isVideoFileName){
          hasVideo = true;
        }else{
          hasFile = true;
        }
      }
      showBottomAction(context,
        actions: [
          if(hasVideo)...[
            if(!hasFile)ItemMenuAction(label: 'Chọn từ tệp'.lang(),
              iconData: ViIcons.file_upload,
              onPressed: ()async{
                appNavigator.pop();
                final res = await AppMediaPicker().pickFiles(
                    allowedExtensions: ext,
                    hasUpload: false
                );
                if(res is List<String>) {
                  _addValue(res);
                }
              }
            ),
            ItemMenuAction(label: 'Video'.lang(),
              iconData: ViIcons.video_courses,
              onPressed: ()async{
                appNavigator.pop();
                final res = await AppMediaPicker().pickVideo(hasUpload: false);
                if(res is String) {
                  _addValue([res]);
                }
              },
            ),
          ],
          if(hasFile)ItemMenuAction(label: 'Chọn từ tệp'.lang(),
              iconData: ViIcons.file_upload,
              onPressed: ()async{
                appNavigator.pop();
                final res = await AppMediaPicker().pickFiles(
                    allowedExtensions: ext,
                    hasUpload: false
                );
                if(res is List<String>) {
                  _addValue(res);
                }
              }
          ),
          if(hasImage)ItemMenuAction(label: 'Chọn từ thư viện'.lang(),
            iconData: ViIcons.image_square,
            onPressed: ()async{
              appNavigator.pop();
              final res = await AppMediaPicker().pickImage(hasUpload: false);
              if(res is String) {
                _addValue([res]);
              }
            },
          ),
          if(hasImage && (!kIsWeb && (Platform.isAndroid || Platform.isIOS)))ItemMenuAction(label: 'Chụp ảnh'.lang(), iconData: ViIcons.camera_plus,
            onPressed: ()async{
              appNavigator.pop();
              final res= await AppMediaPicker().takeImage(hasUpload: false);
              if(res is String) {
                _addValue([res]);
              }
            }
          ),
        ],
        onAction: (context, _){

        }
      );
      return;
    }
    if(requestType == RequestType.common){
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          allowMultiple: parseInt(length) > 1,
          type: FileType.custom,
          allowedExtensions: ext,
        );
        if(result != null && result.files.isNotEmpty){
          List<String> paths = [];
          await Future.forEach(result.files, (e)async{
            paths.add(e.path ?? '');
          });
          _addValue(paths);
        }
      } catch(e) {
        showMessage('Có lỗi xảy ra', type: 'FAIL');
      }

    }else{
      final res = await _selectAssets(
        max: isMultiSelect ? length : 1,
        context: context
      );
      List<String> paths = [];
      await Future.forEach(res, (e)async{
        paths.add(await getAssetFilePath(e));
      });
      _addValue(paths);
    }
  }

  Future<void> _addValue(List<String> paths)async{
    _onChanged();
    final oldValue = !isMultiSelect ? <String, MediaItem>{} : {...state.items};
    int startOrder = oldValue.length + 1;
    ////
    for (var e in paths) {
      final k = '$e-${DateTime.now().millisecondsSinceEpoch}';
      oldValue.addAll({
        k: MediaItem(
          key: k,
          path: e,
          title: getFileName(e),
          sortOrder: '${startOrder++}',
        )
      });
    }
    emit(state.copyWith(items: oldValue));
    _uploads();
  }

  Future<void> _uploads()async{
    await Future.forEach(state.items.values, (e)async{
      await _upload(e);
    });
  }

  Future<void> _upload(MediaItem item)async{
    String? value;
    String? error;
    bool? hasRetry = false;
    int? size;
    if(item.path == null || !empty(item.link)){
      return;
    }

    if (hasBase64) {
      try{
        List<int> imageBytes = File(item.path!).readAsBytesSync();
        String img64 = base64Encode(imageBytes);
        if (!isClosed) {
          value = img64;
        }
      }catch(e){
        error = e.toString();
      }
    }else{

      if (hasUpload) {
        emit(state.update(item.key, item.copyWith(
            isUploading: true,
            hasRetry: false
        )));
        final length = await File(item.path!).length();
        if (sizeLimit > 0 && length >= sizeLimit) {
          if(!isClosed){
            emit(state.remove(item.key));
          }
          showMessage('Vượt quá dung lượng tối đa.'.lang(), type: 'error', timeShow: 5);
          return;
        } else {
          final res2 = await upload(item.path!, onUploading: (process){
            final e = state.getItem(item.key);
            if(e != null && !isClosed) {
              emit(state.update(e.key, e.copyWith(
                  percentUploading: process
              )));
            }
          });
          if (res2 is Map) {
            if(!empty(res2['path'])) {
              value = res2['path'];
              _hasUploaded.addAll({
                item.path!: value
              });
              if(!empty(res2['size'])){
                size = parseInt(res2['size']);
              }
            }else{
              error = res2['error'];
            }
          }else{
            error = 'Tải lên không thành công';
            hasRetry = true;
          }
        }
      } else {
        if (!isClosed) {
          value = item.path!;
        }
      }
    }
    final e = state.getItem(item.key);
    if(!isClosed && e != null){
      emit(state.update(e.key, e.copyWith(
        link: value,
        error: error,
        size: size,
        isUploading: false,
        hasRetry: hasRetry
      )));
      _onChanged();
    }
  }

  void _onChanged(){
    final items = state.items.values.toList()
        .where((e) => !empty(e.link)).toList();
    if(items.isNotEmpty) {
      onChanged(isMultiSelect ? <String, Map<dynamic, dynamic>>{for(var item in items)item.sortOrder: {
        fileKey: item.link,
        'title': item.title,
      if(empty(factories['disableSortOrder']))'sortOrder': item.sortOrder
      }} : items.firstOrNull?.link);
    }else{
      onChanged(isMultiSelect ? <String, Map<dynamic, dynamic>>{} : '');
    }
  }

  String getFixKey(String oldKey){
    if(factoryKeys.isNotEmpty){
      return factoryKeys[oldKey] ?? oldKey;
    }else{
      return oldKey;
    }
  }

  void delete(MediaItem item) {
    emit( state.remove(item.key));
    _onChanged();
  }
  void reUpload(MediaItem item) {
    _upload(item);
  }
}
