import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:vhv_network/src/dio_client.dart';
import 'package:vhv_network/vhv_network.dart';
import 'package:vhv_shared/vhv_shared.dart';
export 'package:dio/dio.dart' show Response;

// ignore: non_constant_identifier_names
var BasicAppConnect = _BasicAppConnect.instance;
class _BasicAppConnect{
  _BasicAppConnect._();
  static _BasicAppConnect? _instance;
  static _BasicAppConnect get instance {
    _instance ??= _BasicAppConnect._();
    return _instance!;
  }
  List<int> successStatusCode = const [200];
  Future<void> resetDio()async{
    await DioClient().clearData();
  }
  
  Dio getDio() => DioClient().dio;

  Map<String, dynamic>? getDefaultHeader(Map<String, dynamic>? customHeader, [bool isMultipart = false]) {
    customHeader ??= <String, dynamic>{};
    customHeader.addAll(<String, dynamic>{
      if(!customHeader.containsKey(HttpHeaders.contentTypeHeader))HttpHeaders.contentTypeHeader: isMultipart ? 'multipart/form-data' : 'application/json; charset=utf-8',
      if(!kIsWeb)...<String, dynamic>{
        if(!customHeader.containsKey(HttpHeaders.acceptHeader))HttpHeaders.acceptHeader: 'application/json',
      },
      if(kIsWeb)...<String, dynamic>{
        // if(!customHeader.containsKey(HttpHeaders.accessControlAllowOriginHeader))HttpHeaders.accessControlAllowOriginHeader: '*',
        // if(!customHeader.containsKey(HttpHeaders.acceptHeader))HttpHeaders.acceptHeader: '*/*',
        // if(!customHeader.containsKey(HttpHeaders.accessControlExposeHeadersHeader))HttpHeaders.accessControlExposeHeadersHeader: '*',
        // if(!customHeader.containsKey(HttpHeaders.accessControlAllowCredentialsHeader))HttpHeaders.accessControlAllowCredentialsHeader: true,
        // if(!customHeader.containsKey(HttpHeaders.accessControlAllowHeadersHeader))HttpHeaders.accessControlAllowHeadersHeader: '*',
        // if(!customHeader.containsKey(HttpHeaders.accessControlAllowMethodsHeader))HttpHeaders.accessControlAllowMethodsHeader: 'GET, POST, OPTIONS'
      }
    });
    return customHeader;
  }

  FutureOr<void> beforeRequest(String url, Map data) async {

  }

  StackTrace? _getStackTrace(){
    String stack = '';
    bool stop = false;
    bool isBaseList = false;
    bool isBase = false;
    final list = StackTrace.current.toString().split('\n');
    list.removeWhere((e) => e == '<asynchronous suspension>');
    for(var i in list){
      if(stop && i.contains('GetBaseListController.')){
        isBaseList = true;
        stop = false;
      }
      if(stop && i.contains('GetBaseController.')){
        isBase = true;
        stop = false;
      }
      if((isBaseList || isBase) && i.contains('Controller.')){
        stack = i;
      }
      if(stop){
        stack = i;
        break;
      }
      if(i.toString().contains('call (package:vhv_network/src/helpers/dio.dart')){
        stop = true;
      }

    }
    if(!empty(stack)){
      if(RegExp(r'(package:[a-zA-Z0-9/._]+)').hasMatch(stack)) {
        final r = RegExp(r'(package:[a-zA-Z0-9/._]+:\d+:\d+)').firstMatch(stack);
        if(!empty(r?.group(1))) {
          return StackTrace.fromString('At file: ${r?.group(1)}');
        }
      }
    }
    return null;
  }

  FutureOr<void> afterResulted(AppConnectResponse response)async {
    final isFromCache = response.response.extra['@fromNetwork@'] == false;
    if(response.params is Map) {
      final track = _getStackTrace();
      log('----------------------- Start ${response.url} (${toRound((response.endTime.millisecondsSinceEpoch
          - response.startTime.millisecondsSinceEpoch)/1000, 2)}s'
          ' at ${date(response.startTime, 'HH:mm:ss')}, ${response.startTime.millisecond}ms'
          '${isFromCache ? ' from Cache': ''}'
          ') ----------------------------');
      if(track != null){
        log(track.toString());
      }
      log('(${response.response.requestOptions.method})VHV.api start: ${response.url}${VHVNetwork.convertDataToUrl(response.params is FormData ?
      (Map<dynamic, dynamic>.fromEntries((response.params as FormData).fields))
          : response.params)}');
      log('VHV.api data: (${response.params})');
      log('VHV.api end: ${response.response.data is Uint8List ? 'Uint8List' : response.response.data}');
      log('----------------------- End ${response.url} ----------------------------');
    }else if(response.response.data is String){
      _checkLogout(response.response.data);
    }
  }

  Future<void> onCatch(AppConnectError error)async{
    final e = error.error;
    if(e is DioException){
      logger.e(e.message??e.error.toString(), error: DioException(
        requestOptions: e.requestOptions,
        error: e.error,
        type: e.type,
        stackTrace: e.stackTrace,
        response: e.response,
        message: '''${error.url}${VHVNetwork.convertDataToUrl((error.params is FormData ?
        (Map<dynamic, dynamic>.fromEntries((error.params as FormData).fields))
            : error.params) ?? {})}
            queryParams: ${error.params}
            statusCode: ${e.response?.statusCode}
            statusMessage: ${e.response?.statusMessage}
            startTime: ${error.startTime}
            endTime: ${error.endTime}'''
      ), stackTrace: e.stackTrace);
    }else{
      logger.e(e.toString(), error: e);
    }
    _checkLogout(error);
  }

  void _checkLogout(dynamic res){
    if(res is AppConnectError){
      final url = res.url;
      final e = res.error;
      if(url.contains('api/Member/User/logout') && e.toString().contains('302')){
        return;
      }else if(e is DioException){
        if((e.response?.headers['location']).toString().contains('/page/login') ||
            (e.response?.headers['location']).toString().contains('/?page=login')){
          _logout();
          return;
        }
      }else{
        _checkLogout(e.toString());
        return;
      }
    }else if(res is String){
      if(res.contains('Access denied! Privilege error: member -> Require login')
          || res.contains('Require login')
          || (res.startsWith('Redirect to:') && res.contains('page=login'))
          || (res.startsWith('<script>location=') && res.contains('/page/login'))
      ){
        _logout();
        return;
      }
    }
  }


  Future<Map<String, dynamic>> getDefaultQuery(String url, Map? params)async{
    Map<String, dynamic> params0 = {};
    if(params != null) {
      params0.addAll(Map<String, dynamic>.from(params));
    }
    final bool hasSite = !empty(params0['usingAppSiteId']);
    if ((params0['site'] == null || params0['site'] == '') && !empty(VHVNetwork.id)) {
      if(hasSite){
        params0['site'] = VHVNetwork.id;
      }else{
        if(!empty(params0['rootSiteId'])){
          params0['site'] = params0['rootSiteId'].toString();
        }else  if(!empty(factories['rootSiteId'])){
          params0['site'] = factories['rootSiteId'].toString();
        }
      }
    }
    params0.remove('usingAppSiteId');
    final bool useRoot = !empty(params0['usingRootSite']);
    if(useRoot && params0.containsKey('site')){
      params0.remove('usingRootSite');
      params0.remove('site');

    }
    if(!empty(factories['groupId'])){
      params0['groupId'] = factories['groupId'];
    }
    if(!empty(factories['appVersion'])){
      params0['appVersion'] = factories['appVersion'];
    }
    if(!empty(factories['setClientLanguage']) && !params0.containsKey('setClientLanguage')){
      params0['setClientLanguage'] = factories['setClientLanguage'];
    }
    if(empty(params0['isAnonymously'])) {
      if (!empty(factories['deviceInfo'])) {
        params0.addAll(factories['deviceInfo']);
      }
      params0['OS'] = getPlatformOS();
      if(params0['OS'] == 'Windows'){
        params0['OS'] = 'Desktop';
      }
    }else{
      params0.remove('isAnonymously');
    }
    if(params0.containsKey('callbackFunction')){
      params0.remove('callbackFunction');
    }
    params0['appVersion'] = await PackageInfoService.version;
    params0['appBundleId'] = await PackageInfoService.packageName;
    params0['securityToken'] = await AppCookieManager().getCsrfToken(getDomain(url) ?? VHVNetwork.domain);
    return params0;
  }


  Future<dynamic> handlingResponseSuccess(AppConnectResponse response) async{
    final res = response.response.data;
    final res0 = (res is String)?res.trim():res;
    if (res0 != null && res0 != '') {
      if (res0 is String && RegExp(r'^\w+$').hasMatch(res0)) {
        return res0;
      }
      try {
        if(response.url == VHVNetwork.domain){
          return res;
        }
        if(res0 is String) {
          if(res0.toString().startsWith('{') || res0.toString().startsWith('[')){
            try{
              final data = jsonDecode(res0);
              if (data is Map && data['status'] == 'expired') {
                appFound(data);
              }
              if (data is Map && data['status'] == 'FAIL' && data['message'] == 'Require login') {
                return await _logout();
              }
              if(data == null){
                return res0;
              }
              return data;
            }catch(e, stack){
              FlutterError.reportError(FlutterErrorDetails(
                exception: e,
                library: 'vhv_network',
                stack: stack,
                context: ErrorDescription('Lỗi BasicAppConnect/handlingResponseSuccess/jsonDecode'),
              ));
              return res0;
            }
          }
        }
        return res0;
      } catch (e) {
        return e.toString();
      }
    }
  }

  void appFound(dynamic res){}



  Future download(String urlPath,
      savePath, {
        ProgressCallback? onReceiveProgress,
        Map<String, dynamic>? queryParameters,
        CancelToken? cancelToken,
        bool deleteOnError = true,
        String lengthHeader = Headers.contentLengthHeader,
        data,
        Options? options,})async{
    final startTime = DateTime.now();
    try {
      Dio dio = getDio();
      if(kIsWeb){
        final res = await dio.downloadForBrowser(urlPath, savePath,
          onReceiveProgress: onReceiveProgress,
          cancelToken: cancelToken,
          deleteOnError: deleteOnError,
          lengthHeader: lengthHeader,
          data: data,
          options: options,
        );
        if(kIsWeb && res.data is Uint8List){
          return res.data;
        }
        return null;
      }
      final res = await dio.download(urlPath, savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError,
        lengthHeader: lengthHeader,
        data: data,
        options: options,
      );
      if(!VHVNetwork.handleSpecialResponse(res)) {
        if (res.data is ResponseBody) {
          if ([200, 201].contains((res.data as ResponseBody).statusCode)) {
            return savePath;
          }
        }
      }
      return '';
    }catch(e){
      if(e is DioException && e.type == DioExceptionType.cancel){
        return true;
      }
      onCatch(AppConnectError(
        url: urlPath,
        error: e,
        params: queryParameters,
        startTime: startTime,
        endTime: DateTime.now(),
      ));
      return '';
    }
  }

  bool allowResult(Response res){
    try{
      return successStatusCode.contains(res.statusCode) || (json.decode(res.data) is Map || json.decode(res.data) is List);
    }catch(_){
      return false;
    }
  }

  Future get(String url, {
    Map? params,
    Map<String, dynamic>? customHeader,
    Options? options,
    ProgressCallback? onReceiveProgress,
    bool handlingResponse = true,
    Dio? customDio,
    bool useDefaultQuery = true,
    CancelToken? cancelToken,
    Function(dynamic error, Function onCatch)? onCatch,
  })async{
    final startTime = DateTime.now();
    try {
      Dio dio = customDio ?? getDio();
      if(customOptions() != null){
        options ??= customOptions();
      }
      if(options != null){
        options.headers = getDefaultHeader(customHeader);
      }
      final queryParams = useDefaultQuery ? {...await getDefaultQuery(url, params)} : toMap<String>(params);
      await beforeRequest(url, queryParams);
      final res = await dio.get(url,
        queryParameters: queryParams,
        options: options,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken
      );
      if(allowResult(res)){
        await afterResulted(AppConnectResponse(
          url: url,
          response: res,
          params: queryParams,
          startTime: startTime,
          endTime: DateTime.now()
        ));
        if(!VHVNetwork.handleSpecialResponse(res)) {
          if (handlingResponse) {
            final response = await handlingResponseSuccess(AppConnectResponse(
                url: url,
                response: res,
                params: queryParams,
                startTime: startTime,
                endTime: DateTime.now()
            ));
            return response;
          } else {
            return res;
          }
        }else{
          return false;
        }
      }
    }catch(e){
      if(VHVNetwork.isCancel(e)){
        rethrow;
      }
      if(onCatch != null){
        onCatch(e, ()async{
          this.onCatch(AppConnectError(
            url: url,
            error: e,
            params: {...await getDefaultQuery(url, params)},
            startTime: startTime,
            endTime: DateTime.now(),
          ));
        });
      }else{
        this.onCatch(AppConnectError(
          url: url,
          error: e,
          params: {...await getDefaultQuery(url, params)},
          startTime: startTime,
          endTime: DateTime.now(),
        ));
      }
    }
  }


  Future post(String url, dynamic params, {
    Map<String, dynamic>? headers,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool handlingResponse = true,
    Dio? customDio,
    CancelToken? cancelToken,
    Function(Object error, Function onCatch)? onCatch,
  })async{
    final startTime = DateTime.now();
    try {
      final dio = customDio ?? getDio();
      if(customOptions() != null){
        options ??= customOptions();
      }


      dynamic queryParams;
      if(params is Map || params == null) {
        queryParams = <String, dynamic>{...await getDefaultData(url, params)};
        await beforeRequest(url, queryParams);
      }else{
        queryParams = params;
      }
      final isMultipart = queryParams is Map && (_containsFile(queryParams)
          || (VHVNetwork.convertDataToUrl(queryParams).length > 2000));
      if(options != null){
        options.headers = getDefaultHeader(headers, isMultipart);
      }

      final res = await dio.post(url,
        data:  isMultipart
            ? FormData.fromMap(Map<String, dynamic>.from(queryParams)) : (queryParams is Map ? null : queryParams),
        queryParameters: (!isMultipart && queryParams is Map) ? Map<String, dynamic>.from(queryParams) : null,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        options: options,
        cancelToken: cancelToken,
      );
      if(allowResult(res)){
        await afterResulted(AppConnectResponse(
          url: url,
          response: res,
          startTime: startTime,
          endTime: DateTime.now(),
          params: queryParams
        ));
        if(!VHVNetwork.handleSpecialResponse(res)) {
          if (handlingResponse) {
            final response = await handlingResponseSuccess(AppConnectResponse(
                url: url,
                response: res,
                startTime: startTime,
                endTime: DateTime.now(),
                params: queryParams
            ));
            return response;
          } else {
            return res;
          }
        }else{
          return false;
        }
      }else{
        throw DioException.badResponse(
          statusCode: res.statusCode ?? 0,
          requestOptions: res.requestOptions,
          response: res
        );
      }
    }catch(e){
      if(VHVNetwork.isCancel(e)){
        rethrow;
      }
      if(onCatch != null) {
        onCatch(e, ()async{
          this.onCatch(AppConnectError(
            url: url,
            error: e,
            params: (params is Map)
              ? {...await getDefaultData(url, params)}
              : params,
            startTime: startTime,
            endTime: DateTime.now(),
          ));
        });
      }else{
        this.onCatch(AppConnectError(
          url: url,
          error: e,
          params: (params is Map)
              ? {...await getDefaultData(url, params)}
              : params,
          startTime: startTime,
          endTime: DateTime.now(),
        ));
      }
    }
  }

  bool _containsFile(dynamic value) {
    if (value is MultipartFile) return true;
    if (value is List) return value.any(_containsFile);
    if (value is Map) return value.values.any(_containsFile);
    return false;
  }

  Future<String?> _logout()async{
    if(account.isLogin()) {
      account.logout(
        localLogout: true
      );
      try{
        if (factories['forceLogoutMessage'] != null) {
          factories['forceLogoutMessage']();
        }
      }catch(_){}
      return 'Require login';
    }
    return null;
  }
  Future<Map<String, dynamic>> getDefaultData(String url, Map? params)async{
    return await getDefaultQuery(url, params);
  }
  dynamic handlingResponseFail(AppConnectResponse response){
    return response.response.data;
  }
  Options? customOptions(){
    return null;
  }
  // String? Function(String serviceName)forceService = (serviceName)=>null;
}
class AppConnectResponse{
  final String url;
  final dynamic params;
  final Response response;
  final DateTime startTime;
  final DateTime endTime;

  AppConnectResponse({required this.startTime, required this.endTime, required this.url,
    required this.params,required this.response});
}
class AppConnectError{
  final String url;
  final dynamic params;
  final dynamic error;
  final DateTime startTime;
  final DateTime endTime;

  AppConnectError({required this.startTime, required this.endTime, required this.url,
    required this.params,required this.error});
}