part of '../../form.dart';


class FormVideoPickers extends StatefulWidget {
  final bool autoPlay;
  final bool hasUpload;
  final ValueChanged? onChanged;
  final List? value;
  final String? labelText;
  final String? errorText;
  final bool enabled;
  final bool chooseNow;
  final int maxVideo;
  final Function(Function)? checkSuccess;

  const FormVideoPickers({super.key, this.autoPlay = false, this.hasUpload = true,
    this.onChanged, this.value, this.labelText, this.errorText,
    this.enabled = true, this.chooseNow = false, this.maxVideo = 3, this.checkSuccess});
  @override
  State<FormVideoPickers> createState() => _FormVideoPickersState();
}

class _FormVideoPickersState extends State<FormVideoPickers> {
  double ratio = 16/9;
  int _currentIndex = 0;
  ImagePicker? picker;
  bool hasPicked = false;
  late List value;
  late Map _value;
  List<AssetEntity> assets = [];


  Future<void> _remove(String key)async{
    if(_value.containsKey(key)){
      String path = _value[key]['assetPath'];
      _value.remove(key);
      final val = await _convertToVal();
      if (widget.onChanged != null) widget.onChanged!(val);
      if(_currentIndex > (_value.length - 1)){
        _currentIndex = _value.length - 1;
      }
      if(_currentIndex < 0)_currentIndex = 0;
      await Future.forEach(assets, (element)async{
        final path0 = await getAssetFilePath(element);
        if(path0 == path){
          assets.remove(element);
        }
      });
      if (mounted) {
        setState(() {});
      }
    }
  }
  Future<List<AssetEntity>> selectAssets([int? max]) async {
    final List<AssetEntity>? result = await PickMethod.cameraAndStay(maxAssetsCount: max??widget.maxVideo,
        requestType: RequestType.video).method(context, assets);
    if (result != null) {
      assets = List<AssetEntity>.from(result);
      return assets;
    }
    return [];
  }
  Future<void> _pick()async{
    if (!hasPicked) {
      hasPicked = true;
      final res = await selectAssets();
      hasPicked = false;
      if (!empty(res)) {
        final path = await getAssetFilePath(res[0]);
        if (widget.hasUpload) {
          _value.addAll({
            path: {
              'file': path,
              'assetPath':path,
              'process': ValueNotifier<double>(0)
            }
          });
          _currentIndex = _value.length - 1;
          if (mounted) setState(() {});
          _upload(path);
        } else {
          _value.addAll({
            path: {
              'file': path,
              'assetPath':path,
              'success': 1,
            }
          });
          value.add(path);
          final val = await _convertToVal();
          if (widget.onChanged != null) widget.onChanged!(val);
        }
      }
    }
  }
  Future<void> _upload(String filePath)async{
    final res = await upload(filePath, process: _value[filePath]['process']);
    if(res is Map){
      if(!empty(res['path'])){
        if(mounted) {
          if(_value.containsKey(filePath)){
            _value[filePath]['fileLocal'] = _value[filePath]['file'];
            _value[filePath]['file'] = res['path'];
            _value[filePath]['success'] = 1;
            _value = _value.map((key, value){
              return MapEntry('${value['file']}', value);
            });
            setState(() {});
            final val = await _convertToVal();
            if (widget.onChanged != null) widget.onChanged!(val);
          }

        }
      }else{
        _value[filePath]['error'] = res['error'];
        showMessage(res['error'], type: 'ERROR');
        // _textError = _res['error'];
        if(mounted) {
          setState(() {});
        }
      }

    }
  }
  Future<List<String>> _convertToVal()async{
    List<String> val = [];
    _value.forEach((key, value) {
      if(!empty(value['success'])){
        val.add(value['file']);
      }
    });
    return val;
  }

  bool _checkSuccess(){
    bool success = true;
    if(!empty(_value)){
      _value.forEach((key, value) {
        if(empty(value['success'])){
          success = false;
        }
      });
    }
    return success;
  }

  @override
  void initState() {
    assets = [];
    if(widget.checkSuccess != null)widget.checkSuccess!(_checkSuccess);
    value = widget.value??[];
    _value = {};
    if(!empty(widget.value)){
      for (var link in widget.value!) {
        _value.addAll({
          '$link':{
            'file': link,
            'success': 1
          }
        });
      }
    }
    picker = ImagePicker();
    if(widget.chooseNow && empty(widget.value))_pick();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(!empty(_value)) {
      final fileInfo = _value.values.elementAt(_currentIndex);
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              BetterVideoPlayer(
                videoLink: fileInfo['fileLocal']??fileInfo['file'],
                autoPlay: false,
                ratio: 1,
                key: ValueKey('FormVideoPickers---${fileInfo['file']}'),
              ),
              if(!empty(fileInfo['process']))ValueListenableBuilder<double>(
                valueListenable: fileInfo['process'],
                builder: (_, value, child){
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: value,
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: value<1?Colors.blue:((empty(fileInfo['error']))?Colors.green:Colors.red),
                              ),
                              height: 3,
                            ),
                          ),
                        ),
                      ),
                      if(value<1)Text('${ "Đang tải lên".lang()} ...', style: const TextStyle(color: Colors.blue)),
                      if(value == 1 && !empty(fileInfo['error']))Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${fileInfo['error']}', style: const TextStyle(color: Colors.red)),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: (){
                              _upload(fileInfo['file']);
                            },
                          )
                        ],
                      ),
                    ],
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(1.0),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4)
                  ),
                  padding: const EdgeInsets.all(3),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                    onPressed: () async {

                      _remove(fileInfo['file']);
                    },
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: 70,
            width: double.infinity,
            color: Colors.black,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: (_value).values.map<Widget>((e) {
                  final int index = _value.keys.toList().indexOf(e['file']);
                  return Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: (index == _currentIndex)
                            ? Colors.blue
                            : Colors.white,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: InkWell(
                        onTap: () async {
                          _currentIndex = (index < 0)?0:index;
                          if (mounted) {
                            setState(() {

                          });
                          }
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: videoThumbnail(e['file'], width: 70),
                        ),
                      ),
                    ),
                  );
                }).toList()
                  ..add((_value.length < widget.maxVideo)?Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Container(
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: InkWell(
                        onTap: () async {
                          _pick();
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add),
                                Text("Thêm".lang()),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ):const SizedBox()
                  ),
              ),
            ),
          )
        ],
      );
    }
    return AspectRatio(aspectRatio: 16/9,
        child: InkWell(
          onTap: widget.enabled?(){
            _pick();
          }:null,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                color: !empty(widget.errorText)?Colors.red[100]:Colors.grey[300],
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.video_collection_outlined),
                      Text(widget.labelText??"Chọn video tải lên".lang())
                    ],
                  ),
                ),
              ),
              if(!empty(widget.errorText))Text(widget.errorText!, style: const TextStyle(color: Colors.red))
            ],
          ),
        ));
  }
}