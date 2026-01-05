part of '../../form.dart';

class FormImageController {
  FormImageController(this._setState,
      {required this.context, required this.formImage});

  final VoidCallback _setState;
  final BuildContext context;
  final FormImage formImage;
  String value = '';
  List<AssetEntity> assets = [];
  late ValueNotifier<bool> loadingNotify;
  bool mounted = true;

  bool get isUploading => loadingNotify.value;

  Future<List<AssetEntity>> selectAssets([int? max]) async {
    List<AssetEntity>? result;
    if (formImage.pickType == PickType.storage) {
      await AppPermissions().requestPhoto();
      if (!context.mounted) {
        return [];
      }
      result = await PickMethod.camera(
          maxAssetsCount: 1,
          requestType: formImage.requestType,
          handleResult: (BuildContext context, AssetEntity result) =>
              Navigator.of(context).pop(<AssetEntity>[result])
      ).method(context, assets);
    } else if (formImage.pickType == PickType.camera) {
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
    if (result != null) {
      assets = List<AssetEntity>.from(result);
      return assets;
    }
    return [];
  }

  Future<dynamic> selectImage() async {
    final res = await selectAssets();
    if (!empty(res)) {
      final path = await getAssetFilePath(res[0]);
      if (formImage.hasBase64) {
        List<int> imageBytes = File(path).readAsBytesSync();
        String img64 = base64Encode(imageBytes);
        if (formImage.onChanged != null) formImage.onChanged!(img64);
        if (mounted) {
          value = img64;
          update();
        }
      } else {
        if (formImage.hasUpload) {
          final length = await File(path).length();
          if (formImage.sizeLimit != null && length >= formImage.sizeLimit!) {
            showMessage("Ảnh vượt quá dung lượng tối đa.".lang(), type: 'ERROR');
            return null;
          } else {
            loadingNotify.value = true;
            final res2 = await upload(path);
            loadingNotify.value = false;
            if (res2 is Map && !empty(res2['path'])) {
              if (formImage.onChanged != null) {
                formImage.onChanged!(
                    res2['path']);
              }
              if (mounted) {
                value = res2['path'];
                update();
              }
            }
          }
        } else {
          if (formImage.onChanged != null) formImage.onChanged!(path);
          if (mounted) {
            value = path;
            update();
          }
        }
      }
      return value;
    }
  }

  void changeValue(String value) {
    this.value = value;
  }

  void delete() {
    if (mounted) {
      value = '';
      assets = [];
      if (formImage.onChanged != null) formImage.onChanged!('');
      update();
    }
  }

  void update() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setState();
      });
    }
  }

  void dispose() {
    mounted = false;
    loadingNotify.dispose();
  }
}

class FormImage extends StatefulWidget {
  final String? fullName;
  final ValueChanged<String>? onChanged;
  final String? value;
  final String? labelText;
  final String? errorText;
  final RequestType requestType;
  final bool enabled;
  final double radius;
  final double width;
  final double? height;
  final double? ratio;
  final int? sizeLimit;
  final bool hideCrop;
  final bool hasUpload;
  final bool hideDeleteBtn;
  final bool hasBase64;
  final PickType pickType;
  final Function(Function() upload)? uploadCallback;
  final Widget Function(FormImageController controller)? layoutBuilder;
  final FocusNode? focusNode;
  final bool hideUploadBtn;

  const FormImage({super.key, this.hasUpload = true, this.fullName,
    this.onChanged, this.value, this.labelText,
    this.errorText, this.enabled = true,
    this.sizeLimit, this.radius = 4, this.width = 100, this.height, this.ratio,
    this.hideCrop = false, this.hasBase64 = false, this.hideDeleteBtn = false,
    this.uploadCallback, this.layoutBuilder, this.pickType = PickType
        .storage, this.requestType = RequestType.image, this.focusNode, this.hideUploadBtn = false,});

  @override
  State<FormImage> createState() => _FormImageState();
}

class _FormImageState extends State<FormImage> {
  late FormImageController formImageController;

  @override
  void didUpdateWidget(FormImage oldWidget) {
    if (widget.value != oldWidget.value) {
      formImageController.changeValue(widget.value ?? '');
    }
    super.didUpdateWidget(oldWidget);
  }


  @override
  void dispose() {
    formImageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    formImageController = FormImageController(() => setState(() {}),
        context: context,
        formImage: widget
    );
    formImageController.loadingNotify = ValueNotifier(false);
    formImageController.changeValue(widget.value ?? '');
    if (widget.uploadCallback != null) {
      widget.uploadCallback!(formImageController.selectImage);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.layoutBuilder != null) {
      return ValueListenableBuilder(
        valueListenable: formImageController.loadingNotify,
        builder: (_, value, child) {
          return widget.layoutBuilder!(formImageController);
        },
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: widget.width,
          height: widget.height ?? (widget.width),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.radius),
              border: (widget.errorText != null) ? Border.all(
                  color: Theme
                      .of(context)
                      .colorScheme
                      .error,
                  width: 1
              ) : Border.all(color: AppColors.border)
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(widget.radius),
                child: InkWell(
                  focusNode: widget.focusNode,
                  radius: widget.radius,
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: widget.enabled ? () async {
                    AppInfo.unfocus();
                    await formImageController.selectImage();
                  } : null,
                  child: Container(
                    color: Colors.white,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: <Widget>[
                        (widget.fullName != null) ? Avatar(
                          widget.fullName ?? '',
                          width: widget.width,
                          radius: widget.radius,
                          image: formImageController.value,
                        ) : Container(
                          decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.05),
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(5))
                          ),
                          child: (!empty(formImageController.value))
                              ? ImageViewer(formImageController.value,
                              notThumb: true,
                              fit: BoxFit.cover, width: widget.width,
                              height: widget.height ?? (widget.width))
                              : const Center(
                            child: Icon(ViIcons.camera),
                          ),
                        ),
                        if(!empty(widget.fullName) &&
                            empty(formImageController.value) && !widget.hideUploadBtn)Container(
                            height: 21,
                            width: 25,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4)
                            ),
                            child: IconButton(
                                color: Colors.white.withValues(alpha: 0.8),
                                padding: EdgeInsets.zero,
                                onPressed: !widget.enabled ? null : () async {
                                  formImageController.selectImage();
                                },
                                icon: const Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Colors.black54,
                                )
                            )
                        ),
                        ValueListenableBuilder<bool>(
                          valueListenable: formImageController.loadingNotify,
                          builder: (_, value, child) {
                            if (value) {
                              return const Loading();
                            }
                            return const SizedBox.shrink();
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
              if(!empty(formImageController.value) &&
                  !widget.hideDeleteBtn)Positioned(
                bottom: 1,
                right: 1,
                child: Container(
                  width: 21,
                  height: 21,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4)
                  ),
                  child: IconButton(
                      color: Colors.red,
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        ViIcons.trash_can,
                        size: 16,
                      ),
                      onPressed: !widget.enabled ? null : () async {
                        formImageController.delete();
                      }
                  ),
                ),
              ),
            ],
          ),
        ),
        if(widget.errorText != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(widget.errorText!, style: Theme
                .of(context)
                .textTheme
                .bodySmall!
                .copyWith(color: Theme
                .of(context)
                .colorScheme
                .error)),
          ),
      ],
    );
  }
}