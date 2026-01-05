import 'dart:async';
import 'dart:io';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:http_cache_hive_store/http_cache_hive_store.dart';
import 'package:vhv_network/vhv_network.dart';
import 'package:vhv_shared/vhv_shared.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import '../src/dio_adapter/browser_not_support.dart'
if(dart.library.html)'package:dio/browser.dart';
import 'dio_adapter/custom_cookie_manager.dart';


class DioClient{
  static final DioClient _instance = DioClient._internal();
  late Dio dio;
  static late DioCacheInterceptor cacheInterceptor;
  late CacheOptions cacheOptions;

  factory DioClient({Dio? customDio}) {
    _instance._setupDio(customDio);
    return _instance;
  }

  DioClient._internal() {
    _setupDio();
  }

  void _setupDio([Dio? customDio]){
    dio = customDio ?? Dio(BaseOptions(
      followRedirects: false,
      connectTimeout: const Duration(seconds: 120),
      receiveTimeout: const Duration(seconds: 120),
      headers: NetworkConfig().defaultHeaders,
    ));
    AppCookieManager().init((cookieJar){
      dio.interceptors.add(CustomCookieManager(cookieJar));
    });
    dio.interceptors.add(_createCacheInterceptor());
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
      ),
    );
    onHttpClientAdapterCreate();
  }

  Future<void> initCsrfToken(List<Site> sites)async{
    await Future.wait(sites.map((site)async{
      await AppCookieManager().getCsrfToken(site.domain);
    }));
  }
  static final cacheStore = appDocumentDirectory != null ? HiveCacheStore('${appDocumentDirectory!.path}/.cache/') : MemCacheStore();

  @protected
  DioCacheInterceptor _createCacheInterceptor(){
    cacheOptions = CacheOptions(
        store: cacheStore,
        hitCacheOnErrorCodes: [500, 502, 503],
        hitCacheOnNetworkFailure: true,
        policy: CachePolicy.request,
      maxStale: Duration(days: 7)
    );
    cacheInterceptor = DioCacheInterceptor(
      options: cacheOptions,
    );
    return cacheInterceptor;
  }




  HttpClient? onHttpClientAdapterCreate() {
    if(factories['onHttpClientAdapterCreate'] is HttpClient? Function(Dio dio)){
      return factories['onHttpClientAdapterCreate'](dio);
    }else {
      if (dio.httpClientAdapter is IOHttpClientAdapter) {
        (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient =
            () {
          final client = HttpClient()
            ..idleTimeout = const Duration(seconds: 3);
          if(kDebugMode) {
            client.badCertificateCallback =
                (X509Certificate cert, String host, int port) => true;
          }
          return client;
        };
      }
      if (dio.httpClientAdapter is BrowserHttpClientAdapter) {
        (dio.httpClientAdapter as BrowserHttpClientAdapter).withCredentials = true;
      }
    }
    return null;
  }

  Future<void> clearCacheAll() async {
    await cacheStore.clean();
  }

  Future<void> clearCache(String service, {String? forceDomain})async{
    final url0 = VHVNetwork.getAPI(service, forceDomain: forceDomain);
    return await cacheStore.delete(CacheOptions.defaultCacheKeyBuilder(url: Uri.parse(url0)));
  }

  Future<void> clearData()async{
    await Future.wait<void>([
      AppCookieManager().clearData(),
      clearCacheAll()
    ]);
  }

  // Map<String, dynamic>? _fakeData;
  // Dio? getFakeDio(String serviceName, {String? forceDomain}){
  //   final url = getAPI(serviceName, forceDomain: forceDomain);
  //   if(_fakeData != null
  //       && _fakeData!.isNotEmpty
  //       && _fakeData!.containsKey(url)){
  //     final fakeDio = Dio(BaseOptions());
  //     fakeDio.interceptors.add(MockInterceptor());
  //     return fakeDio;
  //   }
  //   return null;
  // }
  FutureOr<void> initFakeDio()async{
    // try{
    //   String data = await rootBundle.loadString('mock/fake.json');
    //   final jsonResult = json.decode(data);
    //   if(jsonResult is List) {
    //     _fakeData = { for (var v in jsonResult) '${v['path']??''}' : v};
    //   }
    // }catch(_){}
  }
  bool isNetworkFail(Object e){
    if(e is DioException
        && (e.type == DioExceptionType.connectionError
            || e.type == DioExceptionType.connectionTimeout
            || e.type == DioExceptionType.badResponse
        )){
      return true;
    }
    return false;
  }
}