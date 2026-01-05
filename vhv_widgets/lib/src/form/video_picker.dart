part of '../../form.dart';

class FormVideoPicker extends StatefulWidget {
  final bool hasUpload;
  final ValueChanged? onChanged;
  final String? value;
  final String? labelText;
  final String? errorText;
  final bool enabled;
  final bool chooseNow;
  final double ratio;
  final int? fileSize;

  const FormVideoPicker(
      {super.key, this.hasUpload = true, required this.onChanged, this.value, this.fileSize,
        this.labelText, this.errorText, this.enabled = true, this.chooseNow = false, this.ratio = 16 /
          9});

  @override
  State<FormVideoPicker> createState() => _FormVideoPickerState();
}

class _FormVideoPickerState extends State<FormVideoPicker> {
  ImagePicker? picker;
  bool hasPicked = false;
  String? value;
  String? _value;
  ValueNotifier<double>? _process;
  String? _textError;
  List<AssetEntity>? assets;

  @override
  void initState() {
    value = widget.value ?? '';
    _value = widget.value ?? '';
    assets = [];
    if (widget.hasUpload) _process = ValueNotifier(0.0);
    picker = ImagePicker();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (widget.chooseNow && empty(widget.value)) _pick();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant FormVideoPicker oldWidget) {
    if (widget.value != null && oldWidget.value != widget.value) {
      value = widget.value;
      _value = widget.value ?? '';
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<List<AssetEntity>?> selectAssets([int? max]) async {
    final List<AssetEntity>? result = await PickMethod.camera(
        maxAssetsCount: 1,
        requestType: RequestType.video,
        handleResult: (BuildContext context, AssetEntity result) =>
            Navigator.of(context).pop(<AssetEntity>[result])).method(
        context, assets!);
    if (result != null) {
      assets = List<AssetEntity>.from(result);
      return assets;
    }
    return [];
  }

  Future<void> _pick() async {
    List fileExt = [
      'mp3',
      'avi',
      'mp4',
      'mpg',
      'wmv',
      'wav',
      'mov'
    ];
    final res = await selectAssets();
    if (!empty(res)) {
      final path = await getAssetFilePath(res![0]);
      final ext = path.substring(path.lastIndexOf('.') + 1).toLowerCase();
      final fileSize = await File(path).length();
      if (!empty(widget.fileSize)) {
        if (fileSize > widget.fileSize!) {
          showMessage('Video tải lên vượt quá kích thước', type: 'error');
        }
      }
      if (empty(fileExt.contains(ext))) {
        showMessage('File tải lên không hợp lệ'.lang(), type: 'ERROR');
      } else if (widget.hasUpload) {
        setState(() {
          _value = path;
        });
        _upload(_value!);
      } else {
        _value = path;
        value = path;
        if (mounted) {
          if (widget.onChanged != null) widget.onChanged!(value);
        }
      }


      hasPicked = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _upload(String file) async {
    final res = await upload(file, process: _process);
    if (res is Map) {
      if (!empty(res['path'])) {
        value = res['path'];
        if (mounted) {
          setState(() {});
          if (widget.onChanged != null) widget.onChanged!(value);
        }
      } else {
        showMessage(res['error'], type: 'ERROR');
        _textError = res['error'];
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!empty(_value)) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              BetterVideoPlayer(
                videoLink: _value,
                autoPlay: false,
                ratio: widget.ratio,
              ),
              if(_process != null && empty(value))ValueListenableBuilder<
                  double>(
                valueListenable: _process!,
                builder: (_, valueProcess, child) {
                  double validWidthFactor = valueProcess >= 0.0
                      ? valueProcess
                      : 0.0;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: validWidthFactor,
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: valueProcess < 1 ? Colors.blue : ((empty(
                                    _textError))
                                    ? Colors.green
                                    : Colors.red),
                              ),
                              height: 3,
                            ),
                          ),
                        ),
                      ),
                      if(valueProcess < 1)const Text(
                          'Đang tải lên ...', style: TextStyle(color: Colors
                          .blue)),
                      if(valueProcess == 1 && !empty(_textError))Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$_textError',
                              style: const TextStyle(color: Colors.red)),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () {
                              _upload(value!);
                            },
                          )
                        ],
                      ),
                    ],
                  );
                },
              ),
              if(!empty(value) || !empty(_textError))Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipOval(
                  child: Container(
                    width: 30,
                    height: 30,
                    color: Colors.white,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                          Icons.delete_outline, color: Colors.red, size: 18),
                      onPressed: () {
                        if (mounted) {
                          setState(() {
                            value = '';
                            assets = [];
                            _value = '';
                          });
                          if (widget.onChanged != null) {
                            widget.onChanged!(value);
                          }
                        }
                      },
                    ),
                  ),
                ),
              )
            ],
          ),
          if(!empty(widget.errorText))Text(
              widget.errorText!, style: const TextStyle(color: Colors.red,))
        ],
      );
    }
    return AspectRatio(aspectRatio: widget.ratio,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: InkWell(
            onTap: widget.enabled ? () {
              FocusScope.of(context).requestFocus(FocusNode());
              _pick();
            } : null,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: (context.isDarkMode ? Colors.grey : Colors.grey[100]),
                      border: !empty(widget.errorText) ? Border.all(
                          color: Theme
                              .of(context)
                              .colorScheme
                              .error
                      ) : null
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.video_collection_outlined),
                        Text(widget.labelText ?? "Chọn video tải lên".lang())
                      ],
                    ),
                  ),
                ),
                if(hasPicked)const Align(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                ),
              ],
            ),
          )),
          if(!hasPicked) Container(
            margin: EdgeInsets.only(left: 12, top: 2),
            child: Text(
              '(Chú ý: Hỗ trợ file .mov, .mp4) ${!empty(widget.fileSize)
                  ? 'Tối đa ${toRound(byte2Mb(widget.fileSize!), 2)}MB'
                  : ''}', style: TextStyle(
              fontSize: 12,
            ),),
          ),
          if(!empty(widget.errorText)) Padding(
            padding: const EdgeInsets.only(left: 12, top: 8),
            child: Text(widget.errorText!, style: TextStyle(color: Theme
                .of(context)
                .colorScheme
                .error, fontSize: 12),),),
        ],));
  }
}