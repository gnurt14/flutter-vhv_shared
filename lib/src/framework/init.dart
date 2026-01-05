import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:vhv_core/src/observers/app_lifecycle_observer.dart';
import 'package:vhv_core/vhv_core.dart';
import 'dart:ui';
import 'package:vhv_shared/vhv_shared.dart' as vhv_shared;
import 'package:flutter/foundation.dart';

part '../privates/init_function.dart';
part '../privates/android_device_info_fake.dart';

Future<void> init(
    {required Site site,
    Map<String, Site>? sites,
    List<String>? boxes,
    Iterable<Locale>? supportedLocales,
    Locale? locale,
    ThemeMode? themeMode,
    ThemeData? theme,
    ThemeData? darkTheme,
    RouteFactory? onGenerateRoute,
    String? initialRoute,
    Widget? home,
    Widget? loading,
    bool Function()? checkLoading,
    List<Future<void> Function()>? asyncCallbacks,
    List<Function()>? initializedCallbacks,
    List<VoidCallback>? callbacks,
    List<DeviceOrientation>? orientations,
    List<DeviceOrientation>? tabletOrientations,
    Locale? fallbackLocale,
    bool notShowUpdate = true,
    Widget Function(Widget child)? builder,
    double textScaleFactor = 1.0,
    Function()? onInit,
    Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates,
    final RouterConfig<Object>? routerConfig,
    final String? downloadFolderName,
    AuthHandler? authHandler,
    MaterialAppBuilder? materialAppBuilder,
    List<SingleChildWidget>? providers,
    List<String>? translations,
    BlocWidgetListener<ConfigState>? configListener,
    ScreenBreakpoints? breakpoints,
    List<NavigatorObserver> navigatorObservers = const []
    }) async {
  _validateSite(site, sites);
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  if(kDebugMode) {
    Bloc.observer = SimpleBlocObserver();
  }
  supportedLocales ??= [locale ?? LocaleBloc.defaultLocale];
  if(tabletOrientations != null){
    await Future.delayed(Duration(seconds: 1));
  }
  await _setPreferredOrientations(orientations, tabletOrientations);
  EasyLocalization.logger.enableLevels = [];
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  AppInfo.appVersion = AppVersion(
    version: packageInfo.version,
    buildNumber: packageInfo.buildNumber,
  );
  await VHVStorage.init(boxes: boxes, folderDownload: downloadFolderName);
  final configBloc = ConfigBloc(
    callbacks: callbacks,
    asyncCallbacks: asyncCallbacks,
    initializedCallbacks: initializedCallbacks,
    site: site,
    sites: sites,
    boxes: boxes,
    onHandledData: (res0) {
      _checkUpdate(globalContext, res0);
    },
  )..init();
  final lifecycleObserver = AppLifecycleObserver(configBloc);
  ResponsiveSizingConfig.instance.setCustomBreakpoints(breakpoints ?? const ScreenBreakpoints(
    desktop: 950,
    tablet: 600,
    watch: 300,
  ));
  WidgetsBinding.instance.addObserver(lifecycleObserver);
  EasyLocalization.logger.enableLevels = [];
  runApp(
    EasyLocalization(
      assetLoader: MultipleAssetLoader([
        'translations/',
        'packages/vhv_core/translations/',
        if (translations != null)
          ...translations.map((e) => 'packages/$e/translations/'),
      ]),
      fallbackLocale: fallbackLocale,
      startLocale: LocaleBloc.load(locale ?? const Locale('vi'),
          supportedLocales ),

      saveLocale: false,
      path: 'translations',
      supportedLocales: supportedLocales.toList(),
      child: NavigatorService(
        child: BlocProvider.value(
          value: configBloc,
          child: Builder(
            builder: (context){
              return ColomboApp(
                home: home,
                navigatorObservers: navigatorObservers,
                // locale: locale,
                supportedLocales: supportedLocales ?? [],
                theme: theme,
                darkTheme: darkTheme,
                themeMode: themeMode,
                initialRoute: initialRoute,
                onGenerateRoute: onGenerateRoute,
                routerConfig: routerConfig,
                callbacks: callbacks,
                asyncCallbacks: asyncCallbacks,
                initializedCallbacks: initializedCallbacks,
                site: site,
                sites: sites,
                boxes: boxes,
                authHandler: authHandler ?? const AuthHandler(),
                materialAppBuilder: materialAppBuilder,
                localizationsDelegates: localizationsDelegates,
                loading: loading,
                providers: providers,
                configListener: configListener,
                builder: builder,
              );
            },
          ),
        ),
      ),
    ),
  );
}
class SimpleBlocObserver extends BlocObserver {
  const SimpleBlocObserver();

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    if(show(bloc)) {
      logger.i('${bloc.runtimeType} onCreate', stackTrace: StackTrace.empty);
    }
  }
  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    if(show(bloc)) {
      logger.i('${bloc.runtimeType} onClose', stackTrace: StackTrace.empty);
    }
  }


  bool show(BlocBase bloc){
    return !['FormSelectBloc', 'FormMultipleBloc',
      'FormMediaBloc', 'ConfigBloc',
      'LocaleBloc', 'ThemeModeBloc', 'AccountBloc'
    ].contains(bloc.runtimeType.toString());
  }
}
Future<void> _setPreferredOrientations(
    List<DeviceOrientation>? orientations,
    List<DeviceOrientation>? tabletOrientations,
) async {
  final view = PlatformDispatcher.instance.views.first;

  final physicalSize = view.physicalSize;
  final devicePixelRatio = view.devicePixelRatio;

  final logicalWidth = physicalSize.width / devicePixelRatio;
  final logicalHeight = physicalSize.height / devicePixelRatio;
  final shortestSide =
      logicalWidth < logicalHeight ? logicalWidth : logicalHeight;
  final isTablet = shortestSide >= 550;

  appOrientations = (isTablet ? tabletOrientations : orientations) ??
      [
        DeviceOrientation.portraitUp,
        if (isTablet) ...[
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight
        ]
      ];
  await SystemChrome.setPreferredOrientations(appOrientations);
}

Future<void> _checkUpdate(BuildContext context, Map appInfo) async {
  final appVersion = AppInfo.appVersion;

  if (appVersion.hasNewVersion) {
    final int timeUpdate = parseInt(Setting().get('showUpdateTime'));
    if (appVersion.requiredUpdate ||
        time() - timeUpdate > 43200) {
      Setting().put('showUpdateTime', time());
      Future.delayed(const Duration(seconds: 5), () {
        if(!context.mounted){
          return;
        }
        final bloc = context.read<ConfigBloc>();
        context.read<ConfigBloc>().showAlert(AppAlertData(
            key: 'appUpdate',
            canPop: !appVersion.requiredUpdate,
            title:  "Cập nhật ứng dụng?".lang(),
            message: appVersion.content,
            actions: [
              ItemMenuAction(label: 'Cập nhật ngay'.lang(), iconData: ViIcons.check, onPressed: (){
                urlLaunch(appVersion.updateLink ?? '');
                if(!appVersion.requiredUpdate){
                  bloc.closeAlert();
                }
              }),
              if(!appVersion.requiredUpdate)ItemMenuAction(
                  label: 'Bỏ qua'.lang(),
                  iconData: ViIcons.x_small,
                  onPressed: (){
                    bloc.closeAlert();
                  }
              )
            ]
        ));
      });
    }
  }
}

///----------------------------------Test------------------------------------
// abstract class AppTest{
//   // AppTest._();
//   // static AppTest? _instance;
//   // static AppTest get instance{
//   //   _instance ??= AppTest._();
//   //   return _instance!;
//   // }
//
//   flutter_test.WidgetTester? get tester => _tester;
//   flutter_test.WidgetTester? _tester;
//   RouteFactory? _onGenerateRoute;
//   ThemeData? _theme;
//   ThemeData? _darkTheme;
//   ThemeMode? _themeMode;
//   String? _initialRoute;
//   List<Future<void> Function()>? _callInMyApps;
//   Widget? _loading;
//   bool Function()? _checkLoading;
//
//   Future<void> init({
//     Site? site,
//     Map<String, Site>? sites,
//
//     Locale? startLocale,
//     Locale? fallbackLocale,
//     Iterable<Locale>? supportedLocales,
//
//     LoginOption login = LoginOption.no,
//     bool register = true,
//     List<String>? boxes,
//     ThemeMode? themeMode,
//     ThemeData? theme,
//     ThemeData? darkTheme,
//     RouteFactory? onGenerateRoute,
//     String? initialRoute,
//     Widget? home,
//     Widget? loading,
//     bool Function()? checkLoading,
//     List<Future<void> Function()>? asyncCallbacks,
//     List<Future<void> Function()>? callInMyApps,
//     List<VoidCallback>? callbacks,
//     List<DeviceOrientation>? orientations,
//     bool notShowUpdate = true,
//     Widget Function(Widget child)? builder,
//     String? downloadFolderName
//   })async{
//     await DioManager().initFakeDio();
//     _onGenerateRoute = onGenerateRoute;
//     _theme = theme;
//     _darkTheme = darkTheme;
//     _initialRoute = initialRoute;
//     _themeMode = themeMode ?? ThemeMode.light;
//     _callInMyApps = callInMyApps;
//     _loading = loading;
//     _checkLoading = checkLoading;
//     AppInfo.isTesting = true;
//     await onBeforeInit();
//     _validateSite(site, sites);
//     await _initMockPackageInfo();
//     await _initMockConnectivity();
//     flutter_test.TestWidgetsFlutterBinding.ensureInitialized();
//     HttpOverrides.global = MyHttpOverrides();
//
//     _initializeFactories();
//
//     // if (!kIsWeb) {
//     //   await _initNonWebServices();
//     // }
//     await _initializeSettingsTest(boxes);
//     await _initializeAppConfigTest(
//       site: site,
//       sites: sites,
//       startLocale: startLocale,
//       fallbackLocale: fallbackLocale,
//       supportedLocales: supportedLocales,
//       notShowUpdate: notShowUpdate,
//       login: login,
//       downloadFolderName: downloadFolderName
//     );
//     // await _initializeDio();
//     await _initializeDeviceInfoTest();
//     await _initializeAppLib();
//     await _executeCallbacks(callbacks, asyncCallbacks);
//     appOrientations = orientations ?? [DeviceOrientation.portraitUp];
//   }
//   @protected
//   Future onBeforeInit()async{
//
//   }
//
//   Future<void> pumpColomboApp(
//       flutter_test.WidgetTester tester, {
//         required Widget widget,
//         Duration? duration,
//         flutter_test.EnginePhase phase = flutter_test.EnginePhase.sendSemanticsUpdate,
//         bool wrapWithView = true,
//         Locale? locale,
//         List<Locale> supportedLocales = const [Locale('vi', 'VN')]
//       })async{
//     _tester = tester;
//     await tester.runAsync(() async {
//       await tester.pumpWidget(TickerMode(
//         enabled: false,
//         child: ColomboApp(
//           onGenerateRoute: _onGenerateRoute,
//           theme: _theme,
//           darkTheme: _darkTheme,
//           home: widget,
//           initialRoute: _initialRoute,
//           themeMode: _themeMode ?? ThemeMode.light,
//           locale: locale,
//           // fallbackLocale: AppConfig.fallbackLocale,
//           supportedLocales: supportedLocales,
//           callbacks: _callInMyApps,
//           // loading: _loading,
//           // checkLoading: _checkLoading,
//         ))
//       );
//     });
//   }
// }
class MultipleAssetLoader extends AssetLoader {
  final List<String> paths;

  const MultipleAssetLoader(this.paths);

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    Map<String, dynamic> result = {};
    for (final prefix in paths) {
      final fullPath = '$prefix${locale.languageCode}.json';
      try {
        final data = await rootBundle.loadString(fullPath);
        final jsonMap = json.decode(data) as Map<String, dynamic>;
        result.addAll(jsonMap);
      } catch (_) {
        // Ignore missing or error in file
      }
    }

    return result;
  }
}
