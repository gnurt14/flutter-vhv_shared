  import 'dart:convert';
  import 'dart:io';
  import 'package:flutter/material.dart';
  import 'package:vhv_state/vhv_state.dart';
  import 'package:vhv_widgets/form.dart';
  import 'package:vhv_widgets/src/wechat_asset_picker/constants/picker_method.dart';
  import 'package:vhv_widgets/vhv_widgets.dart';
  import 'package:wechat_camera_picker/wechat_camera_picker.dart';
  export 'package:wechat_camera_picker/wechat_camera_picker.dart' show RequestType;
  class FormMediaPicker extends FormWrapper{
    const FormMediaPicker({
      super.key,
      super.onChanged,
      super.enabled,
      super.value,
      super.errorText,
      ///default 5Mb
      this.sizeLimit = 5242880,
      this.length = 1,
      this.pickType = PickType.storage,
      this.hasBase64 = false,
      this.hasUpload = true,
      this.factoryKeys = const {},
      this.helper,
      this.helperText,
      this.helperMaxLines,
      this.ext = const ['jpg','gif','png','jpeg','bmp', 'heic']
    }):assert(
      length >= 1, 'Số lượng ảnh phải lớn hơn 0'
    ), assert(
      value is String || value is Map || value is List || value == null
    );


    ///Image count. If length > 1 => multi select image
    final int length;
    ///bytes
    /// 5Mb = 5 * 1024 * 1024
    final int sizeLimit;
    final PickType pickType;
    final bool hasBase64;
    final bool hasUpload;
    final Map<String, String> factoryKeys;
    final List<String> ext;
    final String? helperText;
    final int? helperMaxLines;
    final Widget? helper;
    RequestType get requestType => RequestType.image;

    BorderRadius? borderRadius(BuildContext context){
      final border = Theme.of(context).inputDecorationTheme.border
          ?? Theme.of(context).inputDecorationTheme.enabledBorder;
      if(border is OutlineInputBorder){
        return border.borderRadius;
      }
      return null;
    }

    @protected
    Widget addButton(BuildContext context){
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ViIcons.image_plus, color: AppColors.primary,),
          const SizedBox(width: 10,),
          Text("Thêm ảnh".lang(), style: TextStyle(
              color: AppColors.primary
          ),)
        ],
      );
    }
    Widget deleteButton(BuildContext context, MapEntry element, FormMediaPickerController controller){
      if(!enabled){
        return const SizedBox.shrink();
      }
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(36)
        ),
        child: IconButton(
          style: IconButton.styleFrom(
            minimumSize: const Size(36, 36),
             fixedSize: const Size(36, 36),
             maximumSize: const Size(36, 36),
            padding: EdgeInsets.zero,
          ),
          icon: const Icon(ViIcons.trash_can, size: 18, color: Colors.red,),
          onPressed: () => controller.delete(element.key),
        ),
      );
    }
    @protected
    Widget itemView(BuildContext context, MapEntry element, FormMediaPickerController controller){
      return Stack(
        children: [
          AspectRatio(
            aspectRatio: 343/160,
            child: GestureDetector(
              onTap: (){
                openFile(element.value[controller.getFixKey('image')]);
              },
              child: ClipRRect(
                borderRadius: borderRadius(context) ?? BorderRadius.circular(12),
                child: ImageViewer(element.value[controller.getFixKey('image')], notThumb: true, fit: BoxFit.contain,),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            right: 15,
            child: deleteButton(context, element, controller),
          )
        ],
      );
    }
    @protected
    Widget? helperWidget(BuildContext context, FormMediaPickerController controller) {
      return null;
    }

    @override
    State<FormMediaPicker> createState() => _FormMediaPickerState();
  }

  class _FormMediaPickerState extends State<FormMediaPicker> {
    late FormMediaPickerController controller;

    @override
    void initState() {
      controller = FormMediaPickerController(setState,
        context: context,
      )..init();
      controller.updateValue(empty(widget.value)?null:widget.value);
      super.initState();
    }


    @override
    void didUpdateWidget(covariant FormMediaPicker oldWidget) {
      controller.updateValue(empty(widget.value)?null:widget.value);
      super.didUpdateWidget(oldWidget);
    }
    @override
    void dispose() {
      controller.dispose();
      super.dispose();
    }

    bool get showButton{

      if(controller.isMultiSelect){
        return !controller.hasMax;
      }else{

        return empty(controller.values.value)||empty(controller.values.value['1']?['image']);
      }
    }
    bool get showHelperText{
      if(controller.values.value.isNotEmpty){
        return false;
      }
      return true;
    }

    @override
    Widget build(BuildContext context) {
      return ValueListenableBuilder<Map<String, Map>>(
          valueListenable: controller.values,
          builder: (_, value, _) {
            Widget child = const SizedBox.shrink();
            if (!empty(value)) {
              child = ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (_, _) {
                  return const SizedBox(height: 10,);
                },
                itemCount: value.length,
                itemBuilder: (context, index) {
                  final element = value.entries.elementAt(index);
                  return widget.itemView(context, element, controller);
                },
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if(showButton)InputDecoratorBase(
                  onPressed: !controller.isEnabled ? null : () {
                    FocusScope.of(context).unfocus();
                    controller.selectImage(parseInt(widget.length - controller.values.value.length));
                  },
                  decoration: InputDecorationBase(
                      helper: widget.helper ?? (!showHelperText ? null : widget.helperWidget(context, controller)),
                      helperText: widget.helperText ??
                          (!showHelperText ? null : ((widget.helperWidget(context, controller) != null
                              || controller.values.value.isNotEmpty) ? null
                              : "(Chú ý: Hỗ trợ file {fileType}) Tối đa {maxSize}".lang(namedArgs: {
                            'fileType': widget.ext.map((e) => '.$e').toList().join(', '),
                            'maxSize': '${toRound(byte2Mb(widget.sizeLimit), 2)}MB'
                          })
                          )),
                      helperMaxLines: widget.helperMaxLines ?? 2,
                      errorText: widget.errorText
                  ),
                  enabled: widget.enabled,
                  child: ValueListenableBuilder<double>(
                      valueListenable: controller.loadingPercent,
                      builder: (_, value, child) {
                        final isUploading = value > 0 && value < 1;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if(!isUploading)widget.addButton(context),
                            if(isUploading)...[
                              Icon(ViIcons.upload_cloud, color: AppColors.primary,),
                              const SizedBox(width: 10,),
                              Text("Đang tải lên".lang(), style: TextStyle(
                                  color: AppColors.primary
                              ),)
                            ]
                          ],
                        );
                      }
                  ),
                ).paddingOnly(bottom: 10),
                (!showButton && widget.errorText != null) ? InputDecoratorBase(
                  decoration: InputDecorationBase(
                    errorText: widget.errorText,
                  ),
                  child: child,
                ) : child
              ],
            );
          }
      );
    }
  }


  class FormMediaPickerController{
    FormMediaPickerController(this._setState, {required this.context});
    void init(){
      loadingPercent = ValueNotifier(0);
    }
    final void Function(VoidCallback) _setState;
    final BuildContext context;
    FormMediaPicker get widget => context.widget as FormMediaPicker;
    List<AssetEntity> assets = [];
    late ValueNotifier<double> loadingPercent;
    bool mounted = true;
    bool get isUploading => loadingPercent.value > 0 && loadingPercent.value < 1;
    bool get isEnabled => widget.enabled && widget.onChanged != null;
    bool get isMultiSelect => widget.length > 1;
    bool get hasMax => widget.length <= values.value.length;
    int get lengthValid => parseInt(isMultiSelect ? widget.length - values.value.length : 1);

    final Map _hasUploaded = {};
    final values = ValueNotifier<Map<String, Map>>(<String, Map>{});

    Future<List<AssetEntity>> selectAssets([int? max]) async {
      assets.clear();
      if(!isMultiSelect){
        values.value.clear();
      }
      List<AssetEntity>? result;
      if(widget.pickType == PickType.storage) {
        result = await PickMethod.camera(
          maxAssetsCount: max ?? 1,
          requestType: widget.requestType,
          handleResult: (BuildContext context, AssetEntity result) =>
              Navigator.of(context).pop(<AssetEntity>[result])).method(
          context, assets
        );
      }else if(widget.pickType == PickType.camera){
        final AssetEntity? pickResult = await CameraPicker.pickFromCamera(
          context,
          pickerConfig: CameraPickerConfig(
            textDelegate: cameraPickerTextDelegateFromLocale(currentLocale),
            enableRecording: false,
            shouldDeletePreviewFile: true,
          ),
          locale: currentLocale
        );
        if(empty(result) && pickResult != null){
          result = <AssetEntity>[pickResult];
        }
      }
      if (result != null) {
        assets = List<AssetEntity>.from(result);
        return assets;
      }
      return [];
    }
    Future<void> selectImage([int? length])async{
      assert(length == null || length > 0);
      if(widget.requestType == RequestType.common){

        FilePickerResult? result = await FilePicker.platform.pickFiles(
          allowMultiple: parseInt(length) > 1,
          type: FileType.custom,
          allowedExtensions: widget.ext,
        );
        if(result != null && result.files.isNotEmpty){
          final list = result.files.map((e){
            return _upload(e.xFile.path);
          }).toList();
          await Future.wait(list);
        }
      }else{
        final res = await selectAssets(length);
        final list = res.map((e){
          return _upload('', e);
        }).toList();
        await Future.wait(list);
      }
    }
    Future<void> _upload(String path, [AssetEntity? assetEntity])async{
      assert(!empty(path) || assetEntity != null);
      path = !empty(path) ? path : (await getAssetFilePath(assetEntity));
      String value = '';
      if (widget.hasBase64) {
        List<int> imageBytes = File(path).readAsBytesSync();
        String img64 = base64Encode(imageBytes);
        if (widget.onChanged != null) widget.onChanged!(img64);
        if (mounted) {
          value = img64;
        }
      }else{
        if (widget.hasUpload) {
          if(_hasUploaded.containsKey(path)){
            value = _hasUploaded[path];
          }else {
            final length = await File(path).length();

            if (length >= widget.sizeLimit) {
              showMessage(
                  'Ảnh vượt quá dung lượng tối đa.'.lang(), type: 'ERROR');
            } else {
              loadingPercent.value = 0.00001;
              final res2 = await upload(path, process: loadingPercent);
              if (res2 is Map && !empty(res2['path'])) {
                //Trả ra Map thay vì String ngay từ đầu
                // if (widget.onChanged != null) widget.onChanged!(isMultiSelect ? res2 :res2['path']);
                // if (widget.onChanged != null) widget.onChanged!(res2['path']);
                value = res2['path'];
                _hasUploaded.addAll({
                  path: value
                });
              }
            }
          }
        } else {
          if (widget.onChanged != null) widget.onChanged!(path);
          if (mounted) {
            value = path;
          }
        }
      }
      if(!empty(value)){
        addValue(value);
      }
    }
    Map<String, Map> getValues(dynamic value){
      if(value == null){
        return {};
      }
      if(value is String){
        return {
          '1': {
            getFixKey('image'): value,
            getFixKey('title'): getFileName(value),
            getFixKey('sortOrder'): '1'
          }
        };
      }else{
        int index = 1;
        return { for (var v in toList(value)) '$index' : {
          getFixKey('image'): v[getFixKey('image')],
          getFixKey('title'): v[getFixKey('title')] ?? getFileName(v[getFixKey('image')] ?? ''),
          getFixKey('sortOrder'): '${index++}'
        } };
      }
    }
    void addValue(String image){
      if(values.value.length < widget.length && mounted) {
        values.value = <String, Map>{...values.value}..addAll(<String, Map>{
          '${values.value.length + 1}': {
            getFixKey('image'): image,
            getFixKey('title'): getFileName(image),
            getFixKey('sortOrder'): '${values.value.length + 1}'
          }
        });
        onChanged();
      }
    }

    void onChanged() {
      if (widget.onChanged != null && mounted) {
        if (values.value.isNotEmpty) {
          // Truyền toàn bộ Map vào onChanged
          widget.onChanged!( isMultiSelect ? values.value : values.value.values.first[getFixKey('image')]);
          // widget.onChanged!(values.value);
        } else {
          // Trường hợp không có ảnh, truyền Map rỗng
          widget.onChanged!(isMultiSelect?<String, Map>{}:'');
        }
      }
    }

    // void onChanged(){
    //   if (widget.onChanged != null && mounted) {
    //     if(values.value.isNotEmpty) {
    //       widget.onChanged!(
    //           isMultiSelect ? values.value : values.value.values.first[getFixKey('image')]
    //       );
    //     }else{
    //
    //       widget.onChanged!(
    //           isMultiSelect ? {} : {}
    //       );
    //     }
    //   }
    // }
    String getFixKey(String oldKey){
      if(widget.factoryKeys.isNotEmpty){
        return widget.factoryKeys[oldKey] ?? oldKey;
      }else{
        return oldKey;
      }
    }
    void updateValue(dynamic value) {
      final oldValue = getValues(value);
      if(oldValue.length > widget.length){
        oldValue.removeWhere((k, v) => parseInt(k) > widget.length);
      }
      values.value = oldValue;
    }

    void delete(String key){
      values.value.remove(key);
      if (values.value.isEmpty) {
        // Nếu Map trở thành rỗng, gán lại một Map<String, dynamic> rỗng
        values.value = <String, Map>{};
      }
      onChanged();
    }
    void update(){
      if(mounted){
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _setState((){});
        });
      }
    }
    void dispose(){
      mounted = false;
      loadingPercent.dispose();
      values.dispose();
    }

  }