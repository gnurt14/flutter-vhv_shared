part of '../helper.dart';

Future<String?> selectImage({double? ratio, int? width, bool hasUpload = true,
  int? sizeLimit, bool hideCrop = false, bool requestPermission = false}) async {
  final res = await AppPermissions().requestPhoto();
  if(!res){
    return null;
  }
  File? img;
  final ImagePicker picker = ImagePicker();

  final XFile? image = await picker.pickImage(source: ImageSource.gallery,);
  if(image is XFile) {
    img = File(image.path);
  }
  if(img is File) {
    final title = 'img-temp-fix${img.path.substring(img.path.lastIndexOf('.'))}';
    final file = await VHVStorage.getFilePath(title, false);
    File temp = await img.copy(file);
    File rotatedImage =
    await FlutterExifRotation.rotateImage(path: temp.path);
    String filePath = rotatedImage.path;
    if (!empty(ratio) && !hideCrop) {
      final image = await _cropImage(filePath, ratio!);
      if(!empty(image)) {
        filePath = image;
        final length = await File(filePath).length();
        if (sizeLimit != null && length >= sizeLimit) {
          showMessage('Ảnh vượt quá dung lượng tối đa.'.lang(), type: 'ERROR');
          return null;
        }
      }else{
        return null;
      }
    }else{
      final length = await (img.length());
      if(sizeLimit != null && length >= sizeLimit){
        showMessage('Ảnh vượt quá dung lượng tối đa.'.lang(),type: 'ERROR');
        return null;
      }
    }
    if (hasUpload) {
      final res = await upload(filePath, fileName: img.path.substring(img.path.lastIndexOf('/') + 1));
      await Future.delayed(const Duration(seconds: 2));
      temp.delete();
      if (res is Map) {
        if(!empty(res['path'])) {
          return res['path'];
        }else if(!empty(res['message'])){
          showMessage(res['message'], type: 'error');
        }
      }
    }else{
      return filePath;
    }
  }
  return '';
}

Future<String?> fixRotateImage(String? path)async{
  if(path == null){
    return null;
  }
  try{
    File rotatedImage =
    await FlutterExifRotation.rotateImage(path: path);
    String filePath = rotatedImage.path;
    return filePath;
  }catch(_){
    return path;
  }
}

Future<ui.Image?> getImageSize(String url)async{
  late Image image;
  if(url.startsWith('data:image')){
    RegExp reExp = RegExp(r"data:image/[^;]+;base64,",
        caseSensitive: false, multiLine: false);
    final base64 = url.replaceAll(reExp, '');
    image = Image.memory(
      base64Decode(base64),
    );
  }else if(url.startsWith('http')) {
    image = Image.network(url);
  }else{
    image = Image.file(File(url));
    if(!File(url).existsSync()){
      return null;
    }
  }
  Completer<ui.Image> completer = Completer<ui.Image>();
  image.image
      .resolve(const ImageConfiguration())
      .addListener(
      ImageStreamListener(
              (ImageInfo info, bool _) => completer.complete(info.image)));
  return completer.future;
}


Future<dynamic> _cropImage(String path, double ratio) async {
  CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      aspectRatio: CropAspectRatio(
          ratioX: ratio,
          ratioY: 1
      ),
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cắt ảnh'.lang(),
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true
        ),
        IOSUiSettings(
          title: 'Cắt ảnh'.lang(),
        )
      ]
  );
  if (croppedFile != null) {
    return croppedFile.path;
  }
}
Widget playVideo(String data,
    {isFullscreen = false,
      bool? autoPlay,
      ValueNotifier? listener,
      double? ratio,
      StreamSink? valueListener,
      Stream<bool>? fullScreenControl,
      dynamic controller,
      YoutubePlayerController? youtubePlayerController,
      bool isFullPage = false
    }) {
  RegExp reExpId = RegExp(
      r'(?:youtube\.com/(?:[^/]+/.+/|(?:v|e(?:mbed)?)/|.*[?&]v=)|youtu\.be/)([^"&?/\s]{11})',
      caseSensitive: false,
      multiLine: false);
  RegExp reExpVimeo = RegExp(
      r'(http|https)?://(www\.)?vimeo.com/(([^/]*)/videos/|)(\d+)(?:|/\?)',
      caseSensitive: false,
      multiLine: false);
  if (reExpId.hasMatch(data)) {
    return YoutubePlay(data,
        autoPlay: autoPlay ?? true,
        listener: listener,
        valueListener: valueListener,
        controller: youtubePlayerController);
  } else if (reExpVimeo.hasMatch(data)) {
    final Iterable<Match> matches = reExpVimeo.allMatches(data);
    for (Match? m in matches) {
      if (m?.group(5) != null) {
        return VimeoVideoPlayer(
          id: (m!.group(5))!.toString(),
          valueListener: valueListener,
          controller: controller,
          autoPlay: autoPlay,
        );
      }
    }
  }
  return BetterVideoPlayer(
    ratio: ratio,
    videoLink: data,
    // valueListener: valueListener,
    // controller: controller,
    autoPlay: autoPlay
  );
}

Future<dynamic> imagesPicker([List<AssetEntity>? selected,int? maxImages])async{
  try {
    return await AssetPicker.pickAssets(
      globalContext,
      pickerConfig: AssetPickerConfig(
        maxAssets: maxImages??30,
        selectedAssets: selected ?? [],
      ),
    );
  }catch(e){
    if(!empty(selected))
    {
      return selected;
    }
    else{
      return null;
    }

  }
}

Future<dio.MultipartFile?> convertToBinary(String? path) async {
  if (path != null) {
    return dio.MultipartFile.fromFileSync(path, filename: path.substring(path.lastIndexOf('/') + 1));
  }
  return null;
}
Future<List<Map>> uploadImages(List images, [ValueNotifier<String>? result])async{
  List<Map> res = [];
  int total = images.length;
  int current = 0;
  if(result != null)result.value = '$current/$total';
  await Future.forEach(images, (image)async{
    if(image is AssetEntity) {
      final r = await _uploadImage(image);
      current++;
      if(result != null)result.value = '$current/$total';
      res.add(r);
    }
    else if(image is File) {
      final r = await upload(image.path);
      current++;
      if(result != null)result.value = '$current/$total';
      res.add(r ?? {});
    }

  }).then((response) {

  });
  return res;

}
Future<Map> _uploadImage(AssetEntity image) async{
  var path = await getAssetEntityPath(image);
  if(path != null) {
    final String? name = image.title;
    final Map? res = await upload(path,
      fileName: name!,
    );
    if (res is Map) {
      return res;
    }
  }
  return {};
}
Future<String?> getAssetEntityPath(AssetEntity entity) async {
  final file = await entity.file;
  return file?.path;
}
Future<List<Map>> uploadFiles(List<FileUpload> files)async{
  List<Map> res = [];
  await Future.forEach(files, (FileUpload file)async{
    final r = await _upload(file);
    res.add(r);
  }).then((response) {

  });
  return res;

}
Future<Map> _upload(FileUpload file) async{
  final Map? res = await upload(file.file!.path,
      fileName: file.file!.path.substring(file.file!.path.lastIndexOf('/') + 1),
      process: file.process
  );
  if(res != null && res['path'] != null){
    return res;
  }
  return {};
}

Future<FilePickerResult?>? filePicker({dynamic ext, FileType? fileType, bool allowCompression = false, int? size, bool allowMultiple = false})async {
  if (!empty(ext)){
    assert(ext is String || ext is List<String>, 'Tham số kiểu file lỗi'.lang());
  }
  List<String>? ext0;
  if(ext is List<String>)ext0 = ext;
  if(ext is String){
    ext0 = ext.split(',');
  }
  final FilePickerResult? file = await FilePicker.platform.pickFiles(
      type: fileType!,
      compressionQuality: 1,
      allowedExtensions: ext0,
      allowMultiple: allowMultiple
  );
  return file;
}
String thumbnail(String url, {double width = 480, double ratio = 3/2}) {
  if (!empty(url)) {
    RegExp reExpId = RegExp(
        r'(?:youtube\.com/(?:[^/]+/.+/|(?:v|e(?:mbed)?)/|.*[?&]v=)|youtu\.be/)([^"&?/\s]{11})',
        caseSensitive: false,
        multiLine: false);
    RegExp reExpVimeo = RegExp(
        r'(http|https)?://(www\.)?vimeo.com/(([^/]*)/videos/|)(\d+)(?:|/\?)',
        caseSensitive: false,
        multiLine: false);
    if (reExpId.hasMatch(url)) {
      RegExpMatch? id = reExpId.firstMatch(url);
      return 'https://img.youtube.com/vi/${id!.group(1)}/0.jpg';
    } else if (reExpVimeo.hasMatch(url)) {
      RegExpMatch? id = reExpVimeo.firstMatch(url);
      return 'https://i.vimeocdn.com/video/${id!.group(5)}.webp';
    } else if (url.indexOf('upload/') == 0) {
      int width0 = width.ceil();
      int height = (((width0) / (ratio))).round();
      return '${AppInfo.mediaDomain}/publish/thumbnail/${AppInfo.id}/${width0}x${height}xdefault/$url.png';
    }
  }
  return '';
}


Stack videoThumbnail(String url, {double? width, double? ratio}) {
  Widget? videoImg;
  if (!empty(url)) {
    RegExp reExpId = RegExp(
        r'(?:youtube\.com/(?:[^/]+/.+/|(?:v|e(?:mbed)?)/|.*[?&]v=)|youtu\.be/)([^"&?/\s]{11})',
        caseSensitive: false,
        multiLine: false);
    RegExp reExpVimeo = RegExp(
        r'(http|https)?://(www\.)?vimeo.com/(([^/]*)/videos/|)(\d+)(?:|/\?)',
        caseSensitive: false,
        multiLine: false);
    if (reExpId.hasMatch(url)) {
      RegExpMatch? id = reExpId.firstMatch(url);
      videoImg =
          ImageCacheNetwork('https://img.youtube.com/vi/${id!.group(1)}/0.jpg', fit: BoxFit.cover);
    } else if (reExpVimeo.hasMatch(url)) {
      RegExpMatch? id = reExpVimeo.firstMatch(url);
      videoImg = ImageCacheNetwork(
          'https://i.vimeocdn.com/video/${id!.group(5)}.webp', fit: BoxFit.cover);
    } else if (url.indexOf('upload/') == 0) {
      int width0 = width!.ceil();
      int height = (((width0) / (ratio ?? 1.5))).ceil();
      videoImg = ImageCacheNetwork(
          '${AppInfo.mediaDomain}/publish/thumbnail/${AppInfo.id}/${width0}x${height}xdefault/$url.png', fit: BoxFit.cover);
    }
  }
  return Stack(
    alignment: Alignment.center,
    children: [
      AspectRatio(
          aspectRatio: ratio ?? 3 / 2,
          child: Container(
            width: width,
            color: Colors.black,
            child: videoImg,
          )),
      const Icon(
        Icons.play_circle_outline,
        color: Colors.grey,
        size: 40,
      )
    ],
  );
}

