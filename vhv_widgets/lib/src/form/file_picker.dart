part of '../../form.dart';

class FormFilePicker extends StatefulWidget {
  final dynamic value;
  final List<String>? fileExt;
  final bool multipleUpload;
  final String? labelText;
  final String? errorText;
  final String? hintText;
  final TextStyle? labelStyle;
  final Widget? training;
  final bool enabled;
  final bool hasChangeTitle;
  final InputDecoration? decoration;
  final ValueChanged? onChanged;
  final FileType? fileType;
  final Widget? uploadFileView;
  final Widget? buttonBuilder;
  final bool hasCamera;
  final int? fileSize;
  final Widget? loadingWidget;
  final Function(VoidCallback add, Map<String, Map>)? bodyBuilder;
  final bool hasUpload;

  const FormFilePicker(
      {super.key,
      this.multipleUpload = false,
      this.fileExt,
      this.decoration,
      this.labelText,
      this.errorText,
      this.hintText,
      this.labelStyle,
      this.training,
      this.uploadFileView,
      this.hasChangeTitle = false,
      this.onChanged,
      this.buttonBuilder,
      this.fileSize,
      this.enabled = true,
      this.fileType,
      this.value,
      this.hasCamera = false,
      this.bodyBuilder,
      this.loadingWidget,
        this.hasUpload = true,
    });
  @override
  State<FormFilePicker> createState() => _FormFilePickerState();
}

class _FormFilePickerState extends State<FormFilePicker> {
  late String value;
  late Map<String, Map> values;
  FilePickerResult? _files;
  bool _isSuccess = false;
  bool isSuccess = false;
  String _errorText = '';
  ValueNotifier<double>? _process;
  String _getLabelText(){
    if(!widget.multipleUpload && !empty(value)){
      return value.substring(value.lastIndexOf('/')+1);
    }
    return ((widget.labelText??'Chọn file tải lên').lang());
  }
  dynamic _getValue(){
    if(widget.multipleUpload){
      return values;
    }
    return value;
  }
  @override
  void initState() {
    _errorText = widget.errorText??'';
    _process = ValueNotifier<double>(0.0);
    if(!empty(widget.value)){
      _process!.value = 1;
      _isSuccess = true;
    }
    convertValue();
    if(!empty(_getValue())){
      _process!.value = 1;
    }
    super.initState();
  }
  @override
  void didUpdateWidget(FormFilePicker oldWidget) {
    _errorText = widget.errorText??'';
    convertValue();
    super.didUpdateWidget(oldWidget);
  }

  void convertValue(){
    if(!widget.multipleUpload){
      value = (widget.value is String)?widget.value:'';
    }else{
      values = {};
      if(!empty(widget.value) && widget.value is List){
        widget.value.forEach((element){
          var index = widget.value.indexOf(element);
          if(empty(element['file'])){
            element['file'] = !empty(element['image']) ? element['image'] :'';
          }
          values.addAll({'$index':element});
        });
      }
      else if(widget.value is Map){
        widget.value.forEach((k,v){
          if(empty(v['file'])){
            v['file'] = !empty(v['image']) ? v['image'] :'';
          }
          values.addAll({'$k':v});
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.multipleUpload) {
      return _uploadFile();
    } else {
      return _uploadMultiFiles();
    }
  }

  Future<void> _choseFile() async {
    if (widget.enabled) {
      if (mounted) {
        setState(() {
        _errorText = '';
      });
      }
      if (widget.hasCamera) {
        final res = await showBottomMenu(
          title: "Chọn".lang(),
          child: DefaultTextStyle(
              style: Theme.of(globalContext).textTheme.titleMedium!,
              child: Column(
                children: [
                  InkWell(
                    onTap: ()async{
                      AppInfo.unfocus();
                      appNavigator.pop('camera');
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.camera_alt_outlined),
                          const SizedBox(width: 20),
                          Text("Máy ảnh".lang())
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: ()async{
                      AppInfo.unfocus();

                      appNavigator.pop('library');
                    },
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.photo_library_outlined),
                            const SizedBox(width: 20),
                            Text( "Thư viện".lang())
                          ],
                        )
                    ),
                  ),
                ],
              ),
            )
        );

        if(res == 'camera'){
          if(!mounted){
            return;
          }
          final AssetEntity? result = await CameraPicker.pickFromCamera(
            context,
            pickerConfig: CameraPickerConfig(
              textDelegate: cameraPickerTextDelegateFromLocale(currentLocale),
              enableRecording: true,
            ),
          );
          if (result != null) {
            final File? f = await result.file;
            Uint8List? byte = await result.originBytes;
            int length = await f!.length();
            PlatformFile file = PlatformFile.fromMap({
              'path': f.path,
              'name': result.title,
              'bytes': byte,
              'size': length
            });
            _choseFileContent(file);
          }
        }else{
          _choseFileContent();
        }
      }else{
        await _choseFileContent();
      }
    }
  }
  Future<void> _choseFileContent([PlatformFile? file])async{
    _isSuccess = false;
    List<PlatformFile>? files = [];
    if(file == null) {
      _files = await filePicker(
          fileType: widget.fileType ??
              ((!empty(widget.fileExt)) ? FileType.custom : FileType.any),
          ext: widget.fileExt,
          allowMultiple: widget.multipleUpload
      );
      if(_files != null) {
        files = _files?.files;
      }
    }else{
      files = [file];
    }
    if(!empty(widget.fileExt) && !widget.hasCamera){
      files!.removeWhere((element){
        final ext = element.name.substring(element.name.lastIndexOf('.')+1).toLowerCase();
        if(empty(widget.fileExt!.contains(ext)))showMessage("File tải lên không hợp lệ".lang(),type:'ERROR');
        return empty(widget.fileExt!.contains(ext));
      });
    }

    if(files!.isNotEmpty) {
      _errorText = '';
      if (widget.multipleUpload) {
        int index = values.length + 1;
        for (var element in files) {
          if(!empty(widget.fileSize) &&!empty(element.size) && element.size >= parseInt(widget.fileSize) ) {
            _errorText = '';
            if(!empty(_errorText)){
              _errorText = '$_errorText, ${element.name}';
            }else{
              _errorText = element.name;
            }
          }else{
            String? path = element.path;
            values.addAll({
              '$index': {
                'filePath': path,
                'processNotifier': ValueNotifier<double>(0),
                'title': path!.substring(path.lastIndexOf('/') + 1),
              }
            });
            index++;
          }
        }
        if(!empty(_errorText)){
          _errorText = "{fileName} vượt quá dung lượng cho phép".lang(namedArgs: {
           "fileName" :_errorText
          });
          showMessage(_errorText, type: 'ERROR');
        }
        if (mounted) setState(() {});
        Future.forEach(values.entries, (MapEntry entry) {
          if (!empty(entry.value['filePath'])) {
            _upload(entry.value['filePath'], entry.key, entry.value['processNotifier']);
          }
        }).then((response) {
          if (widget.onChanged != null) widget.onChanged!(values);
          if (mounted) {
            setState(() {
            _isSuccess = true;
          });
          }
        });
      }
      else {
        if (mounted && _files != null) setState(() {});
        if(!empty(widget.fileSize) &&!empty(files[0].size) && files[0].size >= parseInt(widget.fileSize) ){
          _errorText = "{fileName} vượt quá dung lượng cho phép".lang(namedArgs: {
            "fileName":files[0].name
          });
          showMessage(_errorText, type: 'ERROR');
          if (mounted) setState(() {});
        }else{
          if(widget.hasUpload){
            await _upload(files[0]);
          }else{
            setState(() {
              _isSuccess = true;
            });
            widget.onChanged!(files[0].path);
            
          }
          
        }
        if (mounted) {
          setState(() {
          _isSuccess = true;
        });
        }
      }
    }
  }

  Widget _fileInfo(String key, Map value) {
    final String name = value['title']??'';

    return Container(
      // height: 35,
      margin: (widget.multipleUpload) ? const EdgeInsets.only(bottom: 10) : null,
      child: Row(
        children: <Widget>[
          _convertIcon(value['file']??value['image']),
          const SizedBox(
            width: 5,
          ),
          Expanded(
              child: widget.hasChangeTitle
                  ? TextFormField(
                controller: TextEditingController()..text = '${!empty(value['title'])?value['title']:name}',
                decoration: widget.decoration??InputDecorationBase(
                  errorText: widget.errorText,
                ),
                onChanged: (val) {
                  _changeTitle(key, val);
                },
              )
                  : Text(
                  name)),
          if (value['processNotifier'] == null)
            InkWell(
                child: const Icon(Icons.close),
                onTap: () {
                  AppInfo.unfocus();
                  _removeFile(key);
                }),
          if (value['processNotifier'] is ValueNotifier<double>)
            ValueListenableBuilder<double>(
                valueListenable: value['processNotifier'],
                builder: (_, process, child) {
                  if(process > 0 && process < 1) {
                    return Text('${(process * 100).ceil()}%');
                  }else if(process == 1){
                    return InkWell(
                        child: const Icon(Icons.close),
                        onTap: () {
                          AppInfo.unfocus();
                          _removeFile(key);
                        });
                  }else{
                    return const SizedBox();
                  }
                })
        ],
      ),
    );
  }

  Future<dynamic> _upload(dynamic file, [String? key, ValueNotifier<double>? process]) async {
    String path = (file is PlatformFile)?file.path:file;

    final Map? res = await upload(path,
        fileName: path.substring(path.lastIndexOf('/') + 1),
        process: process??_process);
    if (res != null) {
      if (widget.multipleUpload) {
        if(!empty(res['path'])) {
          if (values.containsKey(key)) {
            values[key]?.addAll(<String, dynamic>{
              'file': res['path'],
              'image': res['path'],
              'title': res['title'],
              'sortOrder': key,
            });
            values[key]?.remove('filePath');
            values[key]?.remove('processNotifier');
            if(mounted){
              setState(() {

              });
            }
          }
        }else if(!empty(res['error'])){
          if (values.containsKey(key)) {
            showMessage('${values[key]!['title']} ${res['error']}', type: 'ERROR');
            values.remove(key);
            if(mounted){
              setState(() {
              });
            }
          }
        }
      } else {
        if(mounted){
          setState(() {
            _isSuccess = true;
          });
        }
        if(!empty(res['path'])) {
          value = res['path'];
          if(mounted) {
            setState(() {});
          }
          widget.onChanged!(res['path']);
        }else{
          showMessage('${res['error']??"Thao tác thất bại!".lang()}', type: 'ERROR');
        }
      }
    }
    return true;
  }

  void _changeTitle(String key, String val) {
    if(values.containsKey(key)) {
      values[key]!['title'] = val;
      widget.onChanged!(values);
    }
  }

  Widget _convertIcon([String? fileName]) {
    if (fileName != null) {
      final String ext = fileName.substring(fileName.lastIndexOf('.') + 1);
      IconData iconData;
      switch (ext) {
        case 'doc':
        case 'docx':
          iconData = ViIcons.file_word;
          break;
        case 'xls':
        case 'xlsx':
          iconData = ViIcons.file_excel;
          break;
        case 'ppt':
        case 'pptx':
          iconData = ViIcons.file_powerpoint;
          break;
        case 'pdf':
          iconData = ViIcons.file_pdf;
          break;
        case 'rar':
        case 'zip':
        case '7z':
          iconData = ViIcons.file_attachment;
          break;
        case 'bmp':
        case 'png':
        case 'jpeg':
        case 'jpg':
        iconData = ViIcons.file_attachment;
          break;
        case 'mov':
        case 'mp4':
        case 'flv':
        case 'mpeg':
        case 'avi':
        iconData = ViIcons.file_attachment;
          break;
        case 'mp3':
          iconData = ViIcons.file_attachment;
          break;
        default:
          iconData = ViIcons.attachment;
      }
      return Icon(
        iconData,
        size: 18,
      );
    }
    return const SizedBox();
  }

  void _removeFile(String key) {
    if (widget.enabled) {
      if (widget.multipleUpload) {
        values.remove(key);
        int index = 1;
        Map <String, Map> fileTemps = {};
        values.forEach((k, v) {
          fileTemps.addAll({
            '$index': v
          });
          index++;
        });
        values = fileTemps;

        if(widget.onChanged != null)widget.onChanged!(values);
        setState(() {
          if (!empty(_files) && _files!.files.isEmpty) {
            _isSuccess = false;
          }
        });
      } else {
        _process!.value = 0.0;
        setState(() {
          _isSuccess = false;
          value = '';
        });
        if(widget.onChanged != null)widget.onChanged!(value);
      }
      if (_files == null) {
        _process!.value = 0.0;
      }

    }
  }

  Widget _uploadFile() {
    InputDecorationBase inputDecoration = VHVForm.instance.inputDecoration(widget.decoration);
    inputDecoration = inputDecoration.copyWith(
        enabled: widget.enabled,
        errorText: widget.errorText??inputDecoration.errorText,
        labelText: widget.labelText??inputDecoration.labelText,
        hintText: widget.hintText??inputDecoration.hintText,
        suffixIcon: ValueListenableBuilder<double>(
        valueListenable: _process!,
        builder: (_, process, child) {
          if(process == 1 || !empty(value)) {
            if(_isSuccess || !empty(value)) {
              return IconButton(
                icon: const Icon(
                  ViIcons.trash_can,
                  color: Colors.red,
                ),
                onPressed: () {
                  _removeFile('1');
                  widget.onChanged!('');
                },
              );
            }else{
              return Center(
                child: widget.loadingWidget ?? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              );
            }
          }
          if (process > 0) {
            if (process < 1) {
              return SizedBox(
                  width: 50,
                  child: Center(
                      child: Text('${(process * 100).ceil()}%')));
            } else {
              return const SizedBox.shrink();
            }
          }
          return !empty(widget.uploadFileView) ?
          widget.uploadFileView!:
          const IconButton(
            onPressed: null,
            icon:
            Icon(Icons.file_upload),
          );
        }),
    );
    if(!widget.enabled){
      inputDecoration = VHVForm.instance.extraInputDecoration(context, inputDecoration.copyWith(
        enabled: false
      ));
    }

    return InputDecoratorBase(
      onPressed: (!empty(widget.enabled))
          ? () async {
        final res = await VHVStorage.requestStoragePermission();
        unFocus();
        if(res) {
          await _choseFile();
        }
      } : null,
      value: _getLabelText(),
      decoration: inputDecoration,
      enabled: widget.enabled,
      child: Text(_getLabelText()),
    );
  }
  void unFocus(){
    FocusScope.of(context).unfocus();
  }

  Widget _uploadMultiFiles() {
    List<Widget> widgets = [];
    if(!empty(values)){
      values.forEach((k, v) {
        widgets.add(_fileInfo(k, v));
      });
    }
    if(widget.bodyBuilder != null && widget.enabled) {
      return Column(
        children: [
          widget.bodyBuilder!(_choseFile, values),
          if (!empty(values))
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widgets
            ),
          if(!empty(_errorText))
            const SizedBox(height: 5),
          if(!empty(_errorText))
            Text(_errorText.lang(),style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ))
        ]
    );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (!empty(values))
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widgets
          ),
        if (widget.enabled)
          TextButton(
              onPressed: () async{
                AppInfo.unfocus();
                final res = await VHVStorage.requestStoragePermission();
                if(res) {
                  _choseFile();
                }
              }, style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).primaryColor
          ),
              child: (widget.buttonBuilder != null)?widget.buttonBuilder!:Row(
                children: <Widget>[
                  const Icon(Icons.add),
                  Text("Thêm file".lang()),
                ],
              ),),
        if(!empty(_errorText))
          const SizedBox(height: 5),
        if(!empty(_errorText))
          Text(_errorText.lang(),style: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontSize: 12,
          ))
      ],
    );
  }
}
