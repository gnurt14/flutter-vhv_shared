part of '../helper.dart';

@protected
const forceUseGET = ['selectAll', 'getTree', 'selectList', 'select', 'getInfo'];

Future<List<Cookie>> getCookies() async {
  if (kIsWeb) {
    return <Cookie>[];
  }
  return await AppCookieManager().getCookies();
}
///For web: trả về Uint8List nếu thành công, trả về null nếu k thể tải file
///For mobile:trả về đường dẫn file sau khi tải xong
Future download(String url,
    {String? savePath,
    String? fileName,
    bool toDownloadFolder = false,
    ValueNotifier<double>? process,
    int? retryCounter,
    bool resSavePath = false,
    CancelToken? cancelToken}) async {
  String url0 = url;
  if(url.startsWith('api/Common/File/view?') || url.startsWith('/api/Common/File/view?')){
    fileName ??= getFileName(url);
  }
  if (url.startsWith('upload/') || url.startsWith('/upload/') || url.startsWith('api/') || url.startsWith('/api/')) {
    url0 = urlConvert(url);
  }
  bool res = false;
  if (empty(retryCounter)) {
    res = await AppPermissions().requestDownload();
  } else {
    res = await AppPermissions().download();
  }
  if (res) {
    if (savePath == null) {
      if (toDownloadFolder) {
        savePath = await VHVStorage.getFilePath(fileName ?? url);
      } else {
        var tempDir = await getApplicationDocumentsDirectory();
        String fileName0 = !empty(fileName)
            ? fileName!
            : url.substring(url.lastIndexOf('/') + 1);
        if (url.indexOf('upload/') == 0) {
          fileName0 =
              url.substring(url.indexOf('/', 7) + 1).replaceAll('/', '-');
        }
        if (fileName != null) {
          fileName0 = fileName;
        }

        savePath = '${tempDir.path}/$fileName0';
      }
    }
    if (url.indexOf('upload/') == 0) url0 = urlConvert(url);
    try {
      if(savePath.contains('?')){
        savePath = savePath.substring(0, savePath.indexOf('?'));
      }
      final res = await BasicAppConnect.download(
        url0,
        savePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          debugPrint('${received / total}');
          if (process != null) {
            process.value = received / total;
          }
        },
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          }),
      );
      if(kIsWeb){
        return res is Uint8List ? res : null;
      }
      return res;
    } catch (e) {
      debugPrint('$e');
    }
  } else {
    if ((retryCounter ?? 0) < 20) {
      await Future.delayed(const Duration(seconds: 6));
      return await download(url,
          savePath: savePath,
          fileName: fileName,
          toDownloadFolder: toDownloadFolder,
          process: process,
          retryCounter: (retryCounter ?? 0) + 1);
    } else {
      showMessage(lang(
          'Bạn vui lòng cấp quyền truy cập bộ nhớ để thực hiện được tính năng này!'));
    }
  }
}

Future<Map?> upload(String filePath,
    {String? fileName,
    ValueNotifier<double>? process,
    String? fieldName,
    String? service,
    MultipartFile? file,
    Function(double percent)? onUploading,
    Function(dynamic error)? onError}) async {
  final int time = (DateTime.now()).millisecondsSinceEpoch;
  debugPrint('upload: $filePath');
  final MultipartFile file0 =
      file ?? MultipartFile.fromFileSync(filePath, filename: fileName);

  String url = VHVNetwork.getAPI(service ?? 'qqupload.php');
  Map<String, dynamic> params = {
    if (!empty(VHVNetwork.id, true) &&
        VHVNetwork.useSiteId(service ?? 'qqupload.php'))
      'site': VHVNetwork.id,
    'securityToken': AppCookieManager().csrfToken(url),
    fieldName ?? 'qqfile': file0
  };
  FormData formData = FormData.fromMap(params);
  try {
    return await BasicAppConnect.post(
      url,
      formData,
      onSendProgress: (int sent, int total) {
        if(onUploading != null){
          onUploading((sent / total) / 2);
        }
        if (process != null) {
          process.value = (sent / total) / 2;
        }
      },
      onReceiveProgress: (int sent, int total) {
        if(onUploading != null){
          onUploading(0.5 + (sent / total) / 2);
        }
        if (process != null) {
          process.value = 0.5 + (sent / total) / 2;
        }
      },
      handlingResponse: false,
    ).then((res) {
      debugPrint(
          'StartAPI (${((DateTime.now()).millisecondsSinceEpoch - time) / 1000}s) ${VHVNetwork.domain}/qqupload.php');
      debugPrint('data: ($params)');
      debugPrint('response: ${res.data} End API');
      return jsonDecode(res.toString());
    });
  } catch (e) {
    debugPrint('$e');
  }
  return null;
}

Future<dynamic> call<T>(
  String? serviceName, {
  Map? params,
  Duration? cacheTime,
  Options? options,
  bool hasSite = true,
  String? forceDomain,
  bool forceCache = false,
  RequestMethodType? requestMethod,
  bool isTest = false,
  Dio? customDio,
  CancelToken? cancelToken,
  int totalRetries = 3,
  T? Function(Response? response)? onHandleResponse,
  bool handleCatch = false,
  bool handleSpecialCase = false,
  Function(String urlRedirect)? onRedirect
}) async {
  assert(totalRetries >= 0);
  if(!kDebugMode && params?.containsKey('colomboDebug2') == true){
    params?.remove('colomboDebug2');
  }
  if (serviceName == null) return null;
  bool useGet = requestMethod == RequestMethodType.get;
  if (requestMethod == null) {
    for (var a in forceUseGET) {
      if (serviceName.contains('.$a')) {
        useGet = true;
        break;
      }
    }
  }
  final url = VHVNetwork.getAPI(serviceName, forceDomain: forceDomain);
  if (hasSite && VHVNetwork.useSiteId(serviceName)) {
    params = {...params ?? {}};
    params.putIfAbsent('usingAppSiteId', () => '1');
  }

  bool flag = true;
  int retryCount = 0;
  Object? error;
  dynamic response;

  Future<dynamic> func() async {
    Options? options;
    try{
      options = cacheTime != null
          ? CacheOptions(
        store: DioClient.cacheStore,
        policy: forceCache ? CachePolicy.forceCache : CachePolicy.request,
        maxStale: cacheTime,
        priority: CachePriority.high,
      ).toOptions()
          : null;
    }catch(e){
      logger.e(e);
    }
    try{
      if (requestMethod == RequestMethodType.post || !useGet) {
        return await BasicAppConnect.post(url, params,
            cancelToken: cancelToken,
            options: options,
            handlingResponse: onHandleResponse == null, onCatch: (e, onCatch) {
              logger.e(e);
              error = e;
              onCatch();
            }
        );
      } else {
        return await BasicAppConnect.get(url,
            params: params,
            cancelToken: cancelToken,
            options: options,
            handlingResponse: onHandleResponse == null,
            onCatch: (e, onCatch) {
              logger.e(e);
              error = e;
              onCatch();
            }
        );
      }
    }catch(e){
      if(VHVNetwork.isCancel(e) && handleCatch){
        rethrow;
      }else{
        error = e;
      }
    }
  }
  while (retryCount <= totalRetries && flag) {
    error = null;
    response = await func();
    if(VHVNetwork.isRedirect(error)){
      flag = false;
    }
    if(VHVNetwork.isNetworkErrorConnect(error)){
      flag = false;
    }
    if(response == false){
      flag = false;
      return false;
    }
    if (T.toString() == 'Type' || response is T) {
      flag = false;
    } else {
      clearCache(url);
      if (flag && retryCount < totalRetries) {
        retryCount++;
        await Future.delayed(const Duration(seconds: 3));
      } else {
        flag = false;
      }
    }
  }

  _writeLog(url: url,
      params: params ?? {},
      serviceName: serviceName,
      hasSite: (hasSite && VHVNetwork.useSiteId(serviceName))
  );
  if (VHVNetwork.isServerError(error)) {
    await Future.delayed(const Duration(seconds: 3));
    logger.w('Call again $url',
        error: error, stackTrace: (error as DioException).stackTrace);
    return await call<T>(
      serviceName,
      params: params,
      cacheTime: cacheTime,
      options: options,
      hasSite: hasSite,
      forceDomain: forceDomain,
      forceCache: forceCache,
      requestMethod: requestMethod,
      isTest: isTest,
      customDio: customDio,
      cancelToken: cancelToken,
      totalRetries: totalRetries,
      onHandleResponse: onHandleResponse,
      handleCatch: handleCatch,
    );
  }
  if(error != null && onRedirect != null
      && VHVNetwork.isRedirect(error)
      && VHVNetwork.getLinkRedirect(error) != ''
  ){
    onRedirect(VHVNetwork.getLinkRedirect(error));
    return null;
  }


  if (handleCatch && error != null) {
    throw error!;
  } else {
    if(VHVNetwork.isNetworkErrorConnect(error)
      && _customErrorNetworkMessage(serviceName)
    ){
      return {
        'status': 'NETWORKERROR',
        'message': "Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối Internet của bạn và thử lại.".lang()
      };
    }
    if(response is String && response.startsWith('Array')){
      response = jsonDecode(response.substring(response.indexOf('{"')));
    }
    if (onHandleResponse != null) {
      return onHandleResponse(response);
    }
    return response;
  }
}
bool _customErrorNetworkMessage(String service){
  if(service.endsWith('.login')
    || service.endsWith('.edit')
    || service.endsWith('.update')
  ){
    return true;
  }
  return false;
}


@protected
Future<void> _writeLog({
  required String url,
  required String serviceName,
  bool hasSite = false,
  required Map params
}) async {
  if (!account.isLogin()) {
    return;
  }
  final Map data = Setting().get('vhvVisitedObjects') ?? {};
  String type = _getLogType(serviceName);
  String id = _getIdFromParams(params) ?? '';
  if (_shouldUpdateLog(id, type, data)) {
    _updateVisitedObjects(type, id, data);
    await Setting().put('vhvVisitedObjects', data);
    Future.delayed(const Duration(seconds: 1), () async {
      if (account.isLogin()) {
        try {
          await call('Common.Statistic.Client.request',
              params: {
                'type': type,
                'itemId': id,
                'deviceType': _getDeviceType(),
                'osType': getPlatformOS().firstLowerCase(),
              },
              forceDomain: getDomain(url),
              hasSite: hasSite || !empty(params['site'])) || !empty(params['usingAppSiteId']);
        } catch (_) {}
      }
    });
  }
}

String _getLogType(String service) {
  final reg = RegExp(r'.(Product|Article|Post|Courseware|Book).');
  if (service.endsWith('.select') &&
      reg.hasMatch(service)) {
    return reg.firstMatch(service)?.group(1) ?? 'System';
  } else if (service.startsWith('Group.')) {
    return 'Group';
  }
  return 'System';
}

String? _getIdFromParams(Map params) {
  return checkType<String>((params['id'] ?? params['itemId'])) ?? '';
}

bool _shouldUpdateLog(String id, String type, Map data) {
  if (type == 'System') {
    return empty(data[type]) || ((time() - 180) > parseInt(data[type]));
  } else {
    final Map? list = data[type] as Map?;
    if (list != null) {
      return empty(list[id]) || ((time() - 3600) > parseInt(list[id]));
    }
    return true;
  }
}

void _updateVisitedObjects(String type, String id, Map data) {
  if (type == 'System') {
    data[type] = time();
  } else {
    final Map list = checkType<Map>(data[type]) ?? {};
    list[id] = time();
    data[type] = list;
  }
}

String _getDeviceType() {
  return !empty(globalContext.isTablet) ? 'tablet' : 'mobile';
}

Future<void> clearAllCache() async {
  await DioClient().clearCacheAll();
}

Future<void> clearCache(String url) async {
  await DioClient().clearCache(url);
}
