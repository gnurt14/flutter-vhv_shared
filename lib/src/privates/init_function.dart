part of '../framework/init.dart';
//
// Future<void> _initCamera()async{
//   if(AppInfo.isAndroid || AppInfo.isIOS){
//     try {
//       await availableCameras().then((camera) {
//         cameras = camera;
//       }).catchError((_) {
//       });
//     } on CameraException catch (_) {
//     }
//   }
// }
void _validateSite(Site? site, Map<String, Site>? sites) {
  assert(site != null || sites != null, 'Chưa gán site');
  if (site != null) {
    assert(site.domain.startsWith('https://'), 'Domain phải là https');
  }
  sites?.forEach((_, value) {
    assert(value.domain.startsWith('https://'), 'Domain phải là https');
  });
  if(site != null && sites != null){
    assert(sites.values.firstWhereOrNull((s) => s.domain == site.domain) != null);
  }
}
// void _initializeFactories() {
//   final Map<String, dynamic> initFactories = {
//     'header': headerDefault,
//     'login': {},
//     'initialPage': '/Start',
//     'loginSuccess': <Function(Map)>[],
//     'filterBarType': FilterBarType.type1,
//   };
//
//   initFactories.forEach((key, value) {
//     factories.putIfAbsent(key, () => value);
//   });
// }
//
// Future<void> _initNonWebServices() async {
//   await _initCamera();
//   // await _initAppDirectory();
// }
//
// Future<void> _initializeSettings(List<String>? boxes) async {
//   appNavigator = AppNavigator();
//   factories['boxStorage'] = boxes;
//   Setting.appStorage = AppStorage();
//   await Setting.init('Config');
//   if(boxes != null){
//     await Future.forEach(boxes, (box)async{
//       await Setting.init(box);
//     });
//   }
//   account = Account.instance;
// }
//
// Future<void> _initializeSettingsTest(List<String>? boxes) async {
//   final directory = Directory.systemTemp.createTempSync();
//   flutter_test.TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
//       .setMockMethodCallHandler(
//       const MethodChannel('plugins.flutter.io/path_provider'), (
//       MethodCall methodCall) async {
//     if (methodCall.method == 'getExternalStorageDirectory') {
//       return directory.path;
//     }
//     return ".";
//   });
//   Setting.appStorage = AppStorage(directory);
//   await Setting.init('Config');
//   if (boxes != null) {
//     await Setting.init(boxes);
//   }
// }
//
// Future<void> _initializeAppConfig({
//   Locale? startLocale,
//   Locale? fallbackLocale,
//   Iterable<Locale>? supportedLocales,
//   Site? site,
//   Map<String, Site>? sites,
//   bool notShowUpdate = true,
//   required String? downloadFolderName
// }) async {
//   if (notShowUpdate) {
//     factories['notShowUpdate'] = 1;
//   }
//   // await AppConfig.init(
//   //   startLocale: startLocale,
//   //   fallbackLocale: fallbackLocale,
//   //   locales: supportedLocales
//   // );
//   await AppInfo.init(
//     initData: sites != null && sites[currentLanguage] != null
//         ? sites[currentLanguage]!.toJson()
//         : site!.toJson(),
//     downloadFolderName: downloadFolderName
//   );
// }
//
// Future<void> _initializeAppConfigTest({
//   Locale? startLocale,
//   Locale? fallbackLocale,
//   Iterable<Locale>? supportedLocales,
//   Site? site,
//   Map<String, Site>? sites,
//   bool notShowUpdate = true,
//   LoginOption login = LoginOption.no,
//   required String? downloadFolderName
// }) async {
//   if (notShowUpdate) {
//     factories['notShowUpdate'] = 1;
//   }
//   // AppConfig.enableFakeData();
//   // await AppConfig.init(
//   //   startLocale: startLocale,
//   //   fallbackLocale: fallbackLocale,
//   //   locales: supportedLocales,
//   // );
//   await AppInfo.init(
//       initData: (sites != null && sites[currentLanguage] != null)
//       ? sites[currentLanguage]!.toJson()
//       : site!.toJson(),
//       downloadFolderName: downloadFolderName
//   );
// }
//
// // Future<void> _initializeDio() async {
// //   await DioManager().getDio();
// // }
//
// Future<void> _initializeDeviceInfo() async {
//   await DeviceInfoLib().init();
// }
//
// Future<void> _initializeDeviceInfoTest() async {
//   final androidDeviceInfo =
//   AndroidDeviceInfo.fromMap(_fakeAndroidDeviceInfo);
//   await DeviceInfoLib().initTest(androidDeviceInfo);
// }
//
// Future<void> _initializeAppLib() async {
//   await appLibInit(checkType<Map>(Setting('Config')['account']), true);
// }
//
//
// Future<void> _executeCallbacks(List<VoidCallback>? callbacks, List<AsyncCallbackFunc>? asyncCallbacks)async{
//   callbacks?.forEach((func) => func());
//   if (asyncCallbacks != null) {
//     await Future.wait(asyncCallbacks.map((func)async{
//       await func();
//     }));
//   }
// }
//
// Future<void> _initMockPackageInfo()async{
//   TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
//   const MethodChannel('dev.fluttercommunity.plus/package_info'),
//           (MethodCall methodCall) async {
//     if (methodCall.method == 'getAll') {
//       return <String, dynamic>{
//         'appName': 'ABC',  // <--- set initial values here
//         'packageName': 'A.B.C',  // <--- set initial values here
//         'version': '1.0.0',  // <--- set initial values here
//         'buildNumber': ''  // <--- set initial values here
//       };
//     }
//     return null;
//   });
// }
// Future<void> _initMockConnectivity()async{
//   TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
//     const MethodChannel('dev.fluttercommunity.plus/connectivity'),
//     (MethodCall methodCall) async {
//       if (methodCall.method == 'check') {
//         return 'wifi';
//       }
//       return null;
//     }
//   );
// }
// Widget _buildApp(
//     Widget Function(Widget child)? builder,
//     Locale? startLocale,
//     ThemeData? theme,
//     ThemeData? darkTheme,
//     Iterable<Locale>? supportedLocales,
//     ThemeMode? themeMode,
//     Locale? fallbackLocale,
//     RouteFactory? onGenerateRoute,
//     String? initialRoute,
//     List<AsyncCallbackFunc>? callInMyApps,
//     Widget? home,
//     Widget? loading,
//     bool Function()? checkLoading,
//     double textScaleFactor,
//     Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates,
//     GoRouter? goRouter
//     ) {
//   final app = goRouter != null ?
//       ColomboApp.router(
//         locale: startLocale,
//         theme: theme,
//         darkTheme: darkTheme ?? theme,
//         supportedLocales: supportedLocales ?? [const Locale('vi', 'VN')],
//         themeMode: themeMode,
//         routerConfig: goRouter,
//       )
//       : ColomboApp(
//     locale: startLocale ?? const Locale('vi', 'VN'),
//     theme: theme,
//     darkTheme: darkTheme ?? theme,
//     supportedLocales: supportedLocales ?? [const Locale('vi', 'VN')],
//     themeMode: themeMode,
//     // fallbackLocale: fallbackLocale,
//     onGenerateRoute: onGenerateRoute,
//     initialRoute: initialRoute ?? '/',
//     home: home,
//   );
//
//   return (builder != null ? builder(app) : app);
// }
//
//
class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}