part of '../../form.dart';

class FormAlbumUpload extends StatefulWidget {
  final bool enabled;
  final bool chooseNow;
  final dynamic value;
  final bool hasUpload;
  final bool hasChangeAvatar;
  final String? errorText;
  final int maxImage;
  final Function(dynamic value)? onChanged;
  final Function(Function upload)? uploadBuilder;
  final ValueChanged<bool>? onUploading;
  final Function(VoidCallback add, bool hasImage)? buttonBuilder;
  final String fixNameFile;
  final String? buttonText;
  final bool isAssay;
  final bool onlyCamera;
  final Widget Function(String image)? imageBuilder;
  final Future<List> Function()? cameraBuilder;
  final bool isUploading;
  final RequestType? requestType;
  final Function(Map images, bool isList, String fixNameFile)? cameraUploadBuilder;

  const FormAlbumUpload(
      {super.key, this.enabled = true, this.chooseNow = false, this.value,
        required this.onChanged, this.hasUpload = true, this.uploadBuilder, this.errorText,
        this.maxImage = 30, this.hasChangeAvatar = false, this.buttonBuilder,
        this.fixNameFile = 'image', this.buttonText, this.isAssay = false, this.onlyCamera = false,
        this.cameraBuilder, this.imageBuilder, this.onUploading, this.cameraUploadBuilder,
        this.isUploading = false, this.requestType});

  @override
  State<FormAlbumUpload> createState() => _FormAlbumUploadState();
}

class _FormAlbumUploadState extends State<FormAlbumUpload> {
  List<Widget>? _listWidget;
  Map? _images;
  bool isList = false;
  late ValueNotifier<bool> uploading;
  late List<CameraDescription> cameras;

  @override
  void initState() {
    uploading = ValueNotifier(widget.isUploading);
    if (widget.uploadBuilder != null) widget.uploadBuilder!(_upload);
    if (widget.value is List) isList = true;
    _images = {};
    if (!empty(widget.value)) {
      int index = 1;
      _images = (widget.value is List) ? {
        for (var e in widget.value) '${index++}': (e is Map) ? e : <
            String,
            dynamic>{
          'image': e,
          'title': e.toString().substring(e.toString().lastIndexOf('/') + 1)
        }
      } : widget.value;
    }
    _images!.forEach((key, value) {
      value.addAll(<String, dynamic>{
        'isOld': 1
      });
    });
    _init();
    if (widget.chooseNow && empty(_images)) {
      _addMultiFiles();
    }
    super.initState();
  }


  void setUpdateValue() {
    Map imagesTemp = {};
    Map links = {};
    if (!empty(widget.value)) {
      int index = 1;
      imagesTemp = (widget.value is List) ? {
        for (var e in widget.value) '${index++}': (e is Map) ? e : <
            String,
            dynamic>{
          'image': e,
          'title': e.toString().substring(e.toString().lastIndexOf('/') + 1)
        }
      } : widget.value;
    }
    _images!.forEach((key, value) {
      if (!empty(value[widget.fixNameFile])) {
        links.addAll({
          value[widget.fixNameFile]: value
        });
      }
    });
    imagesTemp.forEach((key, value) {
      if (!empty(value[widget.fixNameFile]) &&
          links.keys.contains(value[widget.fixNameFile])) {
        value.addAll(links[value[widget.fixNameFile]]);
      }
    });
    _images = {}..addAll(imagesTemp);
  }

  @override
  void didUpdateWidget(FormAlbumUpload oldWidget) {
    if (widget.value.toString() != oldWidget.value.toString()) {
      setUpdateValue();
      if (widget.uploadBuilder != null) widget.uploadBuilder!(_upload);
      if (widget.cameraUploadBuilder != null) {
        uploading.value = widget.isUploading;
      }
      if (widget.value is List) isList = true;
      _init();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _setKey() {
    int index = 1;
    _images!.forEach((key, value) {
      value.addAll({
        'sortOrder': index,
      });
      index++;
    });
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _init() async {
    _listWidget = [
      (widget.buttonBuilder == null && widget.enabled) ? Container(
        decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.3),
            borderRadius: const BorderRadius.all(Radius.circular(5))
        ),
        child: ValueListenableBuilder<bool>(
          valueListenable: uploading,
          builder: (_, value, child) {
            return InkWell(
              onTap: !value ? () async {
                return _addMultiFiles();
              } : null,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if(!value)...[
                      const Icon(Icons.add_circle_outline),
                      Text((widget.buttonText ?? "Thêm ảnh".lang())
                          .lang())
                    ],
                    if(value)...[
                      const Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                          Icon(Icons.upload_outlined),
                        ],
                      ),
                      Text("Đang tải lên".lang())
                    ]
                  ],
                ),
              ),
            );
          },
        ),
      ) : widget.buttonBuilder!(_addMultiFiles, !empty(_images))
    ];
    bool hasAvatar = false;
    _images!.forEach((key, value) {
      if (!empty(value['isAvatar'])) {
        hasAvatar = true;
      }
    });
    if (!empty(_images)) {
      _images!.forEach((key, value) {
        if (!hasAvatar) {
          value['isAvatar'] = '1';
          hasAvatar = true;
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              widget.onChanged!(isList
                ? _convertImages(_images!).values.toList()
                : _convertImages(_images!));
            }
          });
        }
        if (!empty(value[widget.fixNameFile])) {
          _listWidget!.add(Stack(
            children: [
              (value[widget.fixNameFile] is AssetEntity)
                  ? Image(
                  image: AssetEntityImageProvider(value[widget.fixNameFile],
                      isOriginal: false,
                      thumbnailSize: const ThumbnailSize(300, 300)),
                  width: 300,
                  height: 300,
                  fit: BoxFit.cover) : ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: (widget.imageBuilder != null) ? widget.imageBuilder!(
                      value[widget.fixNameFile]) : ImageViewer(
                    value[widget.fixNameFile],
                    ratio: 1,
                    widthThumb: 200,
                    fit: BoxFit.cover,
                  )),
              if(widget.enabled && widget.hasChangeAvatar)Positioned(
                left: 0,
                top: 0,
                child: InkWell(
                  onTap: () {
                    changeIsAvatar(key);
                    widget.onChanged!(isList ? _convertImages(_images!).values
                        .toList() : _convertImages(_images!));
                  },
                  child: Container(padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.all(Radius.circular(3))),
                    child: Icon(
                      !empty(value['isAvatar'])
                          ? Icons.check_box_outlined
                          : Icons.check_box_outline_blank,
                      color: !empty(value['isAvatar']) ? Colors.blue : Colors
                          .grey,
                      size: 20,
                    ),
                  ),
                ),
              ),
              if(widget.enabled)Positioned(
                top: 0,
                right: 0,
                child: InkWell(
                    onTap: () {
                      _remove(key);
                    },
                    child:
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(7)
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Color(0xff200E32),
                            borderRadius:
                            BorderRadius.all(Radius.circular(5))),
                        padding: const EdgeInsets.symmetric(
                            vertical: 3, horizontal: 3),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    )
                ),
              ),
            ],
          ));
        }
      });
    }
  }

  Future<void> _remove(String key) async {
    if (_images!.containsKey(key)) {
      setState(() {
        _images!.remove(key);
      });
      _setKey();
      widget.onChanged!(
          isList ? _convertImages(_images!).values.toList() : _convertImages(
              _images!));
    }
  }

  Future<List<dynamic>> selectAssets([int? max]) async {
    if (widget.onlyCamera) {
      if (widget.cameraBuilder != null) {
        return await widget.cameraBuilder!();
      } else {
        final AssetEntity? result = await CameraPicker.pickFromCamera(
          context,
          pickerConfig: CameraPickerConfig(
            textDelegate: cameraPickerTextDelegateFromLocale(currentLocale),
            enableRecording: false,
          ),
        );
        if (result is AssetEntity) {
          return <AssetEntity>[result];
        }
      }
    } else {
      if (widget.isAssay) {
        final List<AssetEntity>? result = await PickMethod.cameraAndStay(
          maxAssetsCount: max ?? widget.maxImage,
          requestType: widget.requestType ?? RequestType.image,).method(
            context, getAsset());
        if (result != null) {
          return List<AssetEntity>.from(result);
        }
      } else {
        try {
          final List<AssetEntity>? result = await PickMethod.camera(
            maxAssetsCount: max ?? widget.maxImage,
            requestType: widget.requestType ?? RequestType.image,
            handleResult: (BuildContext context, AssetEntity result) =>
                Navigator.of(context).pop(<AssetEntity>[...getAsset(), result]),
          ).method(context, getAsset());
          if (result != null) {
            return List<AssetEntity>.from(result);
          }
        } catch (_) {}
      }
    }


    return [];
  }

  @override
  Widget build(BuildContext context) {
    _init();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
            itemCount: _listWidget!.length,
            shrinkWrap: true,
            primary: false,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                crossAxisCount: context.isTablet ? 5 : 3
            ),
            itemBuilder: (BuildContext context, int index) {
              if (widget.errorText != null && index == 0) {
                return DecoratedBox(
                  decoration: BoxDecoration(border: Border.all(color: Theme
                      .of(context)
                      .colorScheme
                      .error,), borderRadius: BorderRadius.circular(8),),
                  child: _listWidget![index]);
              }
              return _listWidget![index];
            }
        ),
        if(widget.errorText != null)Text(
          widget.errorText!, style: TextStyle(color: Theme
            .of(context)
            .colorScheme
            .error, fontSize: 13),)
        // if(widget.buttonBuilder != null && widget.enabled)widget.buttonBuilder!(_addMultiFiles, !empty(_images))
      ],
    );
  }

  int getLength() {
    int num = 0;
    _images!.forEach((key, value) {
      if (!empty(value['isOld'])) {
        num++;
      }
    });
    return widget.maxImage - num;
  }

  Future<void> setFiles(List<dynamic> assets) async {
    Map items = {};
    int index = 1;
    List<AssetEntity> oldAssets = [];
    List<AssetEntity> newAssets = [];
    List<String> newFilesPath = [];
    _images!.forEach((key, value) {
      if (!empty(value['isOld'])
          || (value['assetEntity'] is AssetEntity &&
              assets.contains(value['assetEntity']))
          || !empty(value['isCamera'])
      ) {
        items.addAll({
          '${index++}': value
        });
      }
      if (value['assetEntity'] is AssetEntity) {
        oldAssets.add(value['assetEntity']);
      }
    });
    for (var element in assets) {
      if (!oldAssets.contains(element)) {
        if (element is AssetEntity) {
          newAssets.add(element);
        } else if (element is String) {
          newFilesPath.add(element);
        }
      }
    }
    if (newAssets.isNotEmpty) {
      await Future.forEach(newAssets, (AssetEntity element) async {
        final p = await getAssetFilePath(element);
        items.addAll({
          '$index': {
            'title': element.title,
            'assetEntity': element,
            'assetPath': p,
            'sortOrder': index++
          }
        });
      });
    }
    if (newFilesPath.isNotEmpty) {
      for (var element in newFilesPath) {
        items.addAll({
          '$index': {
            'title': element.substring(element.lastIndexOf('/') + 1),
            'isCamera': 1,
            'assetPath': element,
            'sortOrder': index++
          }
        });
      }
    }
    _images = {}..addAll(items);
    if (mounted) {
      setState(() {

      });
    }
  }

  Future<void> _addMultiFiles([List<AssetEntity>? assets]) async {
    FocusScope.of(globalContext).requestFocus(FocusNode());
    if (widget.enabled) {
      cameras = await initCamera();
      if (empty(cameras)) {
        int index = 1;
        String? image;
        final res = await VHVStorage.requestStoragePermission();
        if (!empty(res)) {
          image = await _selectImage();
          if (!empty(image)) {
            _images?.addAll({
              '$index': <String, dynamic>{
                'image': image,
                'title': image.substring(image.lastIndexOf('/') + 1),
                'assetPath': image
              }
            });
            index++;
          }
        }
      } else if (assets == null) {
        if (getLength() > 0) {
          final List<dynamic> assets0 = await selectAssets(getLength());
          if (assets0.isNotEmpty) {
            await setFiles(assets0);
          }
        }
      } else {
        if (assets.isNotEmpty) {
          await setFiles(assets);
        }
      }
      if (widget.hasUpload) {
        uploading.value = true;
        if (widget.onUploading != null) widget.onUploading!(true);
        if (widget.cameraUploadBuilder != null) {
          _images = await widget.cameraUploadBuilder!(_images!, isList, 'file');
        } else {
          await _upload();
        }
        if (widget.onUploading != null) widget.onUploading!(false);
        uploading.value = false;
      }

      if (mounted) {
        setState(() {

        });
      }
      if (widget.onChanged != null) {
        widget.onChanged!(
            isList ? _convertImages(_images!).values.toList() : _convertImages(
                _images!));
      }
    }
  }

  Future<String> _selectImage() async {
    FocusScope.of(globalContext).requestFocus(FocusNode());
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      return image.path;
    }

    return '';
  }

  Future<dynamic> _upload() async {
    List falseItems = [];
    final Map values = {}..addAll(_images!);
    await Future.forEach(values.values, (value) async {
      if (value is Map) {
        var path = value['assetPath'];
        if (empty(value[widget.fixNameFile])) {
          final res = await upload(path);
          if (res is Map) {
            if (!empty(res['path'])) {
              value.addAll(<String, dynamic>{
                widget.fixNameFile: res['path']
              });

              _removeFields(value);
              if (values.containsKey('${value['sortOrder']}')) {
                values.addAll({
                  '${value['sortOrder']}': value
                });
              }
            } else if (!empty(res['error']) &&
                values.containsKey('${value['sortOrder']}')) {
              falseItems.add('${value['sortOrder']}');
              showMessage(res['error'], type: 'error');
            }
          }
        }
      }
    });

    if (!empty(falseItems)) {
      values.removeWhere((key, value) => falseItems.contains(key));
    }
    _images = {}..addAll(values);

    if (mounted) {
      setState(() {

      });
    }
    uploading.value = false;
    if (widget.onUploading != null) widget.onUploading!(false);
    _setKey();
    return isList ? _convertImages(_images!).values.toList() : _convertImages(
        _images!);
  }

  Map _convertImages(Map images) {
    Map temp = {};
    int index = 1;
    images.forEach((key, value) {
      if (value[widget.fixNameFile] is String) {
        temp.addAll({
          '$index': Map.from(value
            ..addAll({
              'sortOrder': index
            }))
        });
        _removeFields(temp['$index']);
        index++;
      }
    });
    return temp;
  }

  void _removeFields(Map value) {
    for (var k in ['assetPath', 'assetEntity', 'isCamera']) {
      value.remove(k);
    }
    if (!widget.hasChangeAvatar) {
      value.remove('isAvatar');
    }
  }

  void changeIsAvatar(String key) {
    _images!.forEach((k, value) {
      if (!empty(value['isAvatar'])) {
        if (key != k) {
          value.remove('isAvatar');
          setState(() {

          });
        }
      } else if (key == k) {
        value.addAll({
          'isAvatar': '1'
        });
        setState(() {});
      }
    });
  }

  List<AssetEntity> getAsset() {
    List<AssetEntity> list = [];
    _images!.forEach((key, value) {
      if (value['assetEntity'] is AssetEntity) {
        list.add(value['assetEntity']);
      }
    });
    return list;
  }
}

