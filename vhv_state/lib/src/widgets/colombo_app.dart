
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vhv_navigation/vhv_navigation.dart';
import 'package:vhv_network/vhv_network.dart';
import 'package:vhv_shared/vhv_shared.dart';
import 'package:vhv_state/vhv_state.dart';

typedef MaterialAppBuilder = Widget Function(
    {required BuildContext context,
    Locale? locale,
    Iterable<Locale> supportedLocales,
    ThemeMode? themeMode,
    ThemeData? theme,
    ThemeData? darkTheme,
    RouteFactory? onGenerateRoute,
    String? initialRoute,
    Widget? home,
    TransitionBuilder? builder,
    required List<NavigatorObserver> navigatorObservers,
    Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates,
    GlobalKey<NavigatorState>? navigatorKey});

class ColomboApp extends StatelessWidget {
  const ColomboApp(
      {super.key,
      this.home,
      this.loading,
      this.loadFailed,
      this.locale,
      this.supportedLocales = const <Locale>[Locale('vi')],
      this.themeMode,
      this.theme,
      this.darkTheme,
      this.localizationsDelegates,
      this.initialRoute,
      this.onGenerateRoute,
      this.onUnknownRoute,
      this.onNavigationNotification,
      this.navigatorObservers = const [],
      this.routeInformationProvider,
      this.routeInformationParser,
      this.routerConfig,
      this.callbacks,
      this.asyncCallbacks,
      this.initializedCallbacks,
      required this.site,
      this.sites,
      this.boxes,
      required this.authHandler,
      this.builder,
      this.materialAppBuilder,
      this.providers,
      this.configListener
  });

  final Widget? home;
  final Widget? loading;
  final Widget Function(BuildContext context)? loadFailed;

  final Locale? locale;
  final Iterable<Locale> supportedLocales;

  final ThemeMode? themeMode;
  final ThemeData? theme;
  final ThemeData? darkTheme;
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;

  final RouterConfig<Object>? routerConfig;
  final RouteFactory? onGenerateRoute;
  final RouteFactory? onUnknownRoute;
  final NotificationListenerCallback<NavigationNotification>?
      onNavigationNotification;

  final List<NavigatorObserver> navigatorObservers;
  final RouteInformationProvider? routeInformationProvider;
  final RouteInformationParser<Object>? routeInformationParser;

  final String? initialRoute;

  final List<Function()>? callbacks;
  final List<Future<void> Function()>? asyncCallbacks;
  final List<Function()>? initializedCallbacks;
  final List<String>? boxes;
  final Site site;
  final Map<String, Site>? sites;

  final AuthHandler authHandler;
  final Widget Function(Widget child)? builder;
  final MaterialAppBuilder? materialAppBuilder;
  final List<SingleChildWidget>? providers;

  final BlocWidgetListener<ConfigState>? configListener;

  Widget myBuilder(BuildContext context, Widget? child) {
    final configBloc = context.read<ConfigBloc>();
    final config = configBloc.state;
    final appTheme = Theme.of(context).extension<AppThemeExtension>();
    if (config.status == ConfigStateStatus.loading ||
        config.status == ConfigStateStatus.initial) {

      return loading ??
          const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
    }
    if (config.status == ConfigStateStatus.error &&
        VHVNetwork.isNetworkErrorConnect(config.error)) {
      return loadFailed != null
          ? loadFailed!(context)
          : Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (appTheme?.logoBuilder != null)
                  appTheme!.logoBuilder!(context).marginOnly(bottom: 20),
                Text(
                  "Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối Internet của bạn và thử lại.".lang(),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: (config.error is DioException)
            ? SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Opacity(
              opacity: 0.7,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '[${(config.error as DioException).response?.statusCode ?? 'FAIL'}] ${(config.error as DioException).message ?? ''}',
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 10,
                    ),
                  ),
                  FutureBuilder<String>(
                    future: VHVNetwork.getPublicIP(),
                    builder: (c, snapshot) {
                      if (snapshot.hasData &&
                          !empty(snapshot.data)) {
                        return Text(
                          snapshot.data ?? '',
                          style: const TextStyle(fontSize: 10),
                        );
                      }
                      return const Text(
                        '--.--.--.--',
                        style: TextStyle(fontSize: 10),
                      );
                    }),

                ],
              ),
            ),
          ),
        )
            : null,
      );
    }
    if (config.data.isEmpty) {
      return loadFailed != null
          ? loadFailed!(context)
          : Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (appTheme?.logoBuilder != null)
                appTheme!.logoBuilder!(context).marginOnly(bottom: 20),
              h20,
              Text(
                config.error is Exception
                    ? config.error.toString()
                    : "Có lỗi".lang(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16
                ),
              ),
              h20,
              _AppRetryCounter(
                onFinish: (reload)async{
                  await configBloc.refresh(true);
                  if(config.status == ConfigStateStatus.error){
                    reload();
                  }
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Opacity(
              opacity: 0.7,
              child: FutureBuilder<String>(
                future: VHVNetwork.getPublicIP(),
                builder: (c, snapshot) {
                  if (snapshot.hasData && !empty(snapshot.data)) {
                    return Text(
                      snapshot.data ?? '',
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const Text(
                    '--.--.--.--',
                    style: TextStyle(fontSize: 10),
                  );
                }
              )
            ),
          ),
        ),
      );
    }
    final mediaQueryData = MediaQuery.of(context);
    final scale = mediaQueryData.textScaler
        .clamp(minScaleFactor: 0.9, maxScaleFactor: 1.1);
    child = MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: scale),
      child: child ?? const Scaffold(),
    );
    final botToastBuilder = BotToastInit();
    final child2 = Stack(
      children: [
        Builder(
          builder: (_){
            if(builder != null){
              return builder!(botToastBuilder(context, child));
            }
            return botToastBuilder(context, child);
          },
        ),

        if(config.alertData != null)Positioned(
            top: 0,
            right: 0,
            left: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: config.alertData!.canPop ? (){
                config.alertData!.onClose?.call();
              } : null,
              child: PopScope(
                canPop: config.alertData!.canPop,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: context.theme.dialogTheme.barrierColor ?? Colors.black.withValues(alpha: 0.3),
                  child: GestureDetector(
                    onTap: (){},
                    child: Center(
                      child: config.alertData?.builder != null
                          ? config.alertData!.builder!(context) : Dialog(
                        backgroundColor: Theme.of(context).cardColor,
                        insetPadding: EdgeInsets.zero,
                        shape: Theme.of(context).dialogTheme.shape ?? RoundedRectangleBorder(
                            borderRadius: baseBorderRadius
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: SizedBox(
                          width: min(context.width - 32, 360),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Stack(
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(config.alertData!.title, style: context.theme.dialogTheme.titleTextStyle,),
                                    h12,
                                    Text(config.alertData!.message, style: context.theme.dialogTheme.contentTextStyle,),
                                    h16,
                                    MultiActionsBottom(
                                      actions: config.alertData!.actions,
                                      hasDivider: false,
                                      padding: EdgeInsets.zero,
                                      useSafeArea: false,
                                    )
                                  ],
                                ),
                                if(config.alertData!.canPop && config.alertData!.onClose != null)Positioned(
                                  top: -15,
                                  right: -15,
                                  child: IconButton(
                                      onPressed: config.alertData!.onClose,
                                      icon: const Icon(ViIcons.x_small)
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
        )
      ],
    );
    if(KeyboardFixer.isIOS15()){
      return KeyboardFixer(
        child: child2,
      );
    }
    return child2;
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveApp(
      builder: (context){
        return MultiBlocProvider(
            providers: [
              BlocProvider(
                  create: (_) => LocaleBloc(
                      locale,
                      (locale != null && supportedLocales.isEmpty)
                          ? [locale!]
                          : supportedLocales), lazy: false),
              BlocProvider(create: (_) => ThemeModeBloc(themeMode), lazy: false,),
              BlocProvider(create: (_) => AccountBloc(authHandler), lazy: false,),
              if (providers != null) ...providers!
            ],
            child: BlocConsumer<ConfigBloc, ConfigState>(
                listener: configListener ?? (context, state) {},
                buildWhen: (prev, current) {
                  return
                    prev.status != current.status
                        || prev.alertData != current.alertData
                        || !mapEquals(prev.data, current.data);
                },
                listenWhen: (prev, current) {
                  return true;
                },
                builder: (context, config) {
                  appContext = context;
                  if (materialAppBuilder != null) {
                    return materialAppBuilder!(
                      context: context,
                      navigatorKey: navigatorGlobalKey,
                      theme: theme,
                      darkTheme: darkTheme,
                      themeMode:
                      context.select((ThemeModeBloc bloc) => bloc.state),
                      locale: context.select((LocaleBloc bloc) => bloc.state),
                      supportedLocales: supportedLocales,
                      localizationsDelegates: [
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate,
                        ...context.localizationDelegates,
                        if (localizationsDelegates != null)
                          ...localizationsDelegates!,
                      ],
                      navigatorObservers: [
                        BotToastNavigatorObserver(),
                        MyNavigatorObserver(),
                        ...navigatorObservers
                      ],
                      home: home,
                      onGenerateRoute: onGenerateRoute,
                      initialRoute: initialRoute,
                      builder: myBuilder,
                    );
                  }
                  if (routerConfig != null) {
                    return MaterialApp.router(
                      debugShowCheckedModeBanner: false,
                      scrollBehavior: MyCustomScrollBehavior(),

                      theme: theme,
                      darkTheme: darkTheme,
                      themeMode:
                      context.select((ThemeModeBloc bloc) => bloc.state),
                      locale: context.select((LocaleBloc bloc) => bloc.state),
                      supportedLocales: supportedLocales,
                      localizationsDelegates: [
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate,
                        ...context.localizationDelegates,
                        if (localizationsDelegates != null)
                          ...localizationsDelegates!,
                      ],
                      routerConfig: routerConfig,
                      builder: myBuilder,
                    );
                  }
                  return MaterialApp(
                    navigatorKey: navigatorGlobalKey,
                    scrollBehavior: MyCustomScrollBehavior(),
                    debugShowCheckedModeBanner: false,
                    theme: theme,
                    darkTheme: darkTheme,
                    themeMode: context.select((ThemeModeBloc bloc) => bloc.state),
                    locale: context.select((LocaleBloc bloc) => bloc.state),
                    supportedLocales: supportedLocales,
                    localizationsDelegates: [
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                      ...context.localizationDelegates,
                      if (localizationsDelegates != null)
                        ...localizationsDelegates!,
                    ],
                    navigatorObservers: [
                      BotToastNavigatorObserver(),
                      MyNavigatorObserver(),
                      ...navigatorObservers
                    ],
                    home: home,
                    onGenerateRoute: onGenerateRoute,
                    initialRoute: initialRoute,
                    onUnknownRoute: onUnknownRoute,
                    builder: myBuilder,
                  );
                }
            )
        );
      }
    );
  }
}
class _AppRetryCounter extends StatefulWidget {
  const _AppRetryCounter({required this.onFinish});
  final Function(VoidCallback reload) onFinish;

  @override
  State<_AppRetryCounter> createState() => _AppRetryCounterState();
}

class _AppRetryCounterState extends State<_AppRetryCounter> {
  late CountdownTimer _timer;
  String time = '10';
  @override
  void initState() {
    reCount();
    super.initState();
  }
  void reCount(){
    _timer = CountdownTimer(seconds: 10, onChanged: (second){
      if(mounted){
        if(second == 0){
          widget.onFinish.call(reCount);
        }
        setState(() {
          time = '$second';
        });
      }
    });
    _timer.start();
  }



  @override
  void dispose() {
    _timer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(TextSpan(
          text: 'Thử lại sau {}'.lang(
              args: ['']
          ),
          children: [
            TextSpan(
              text: '${time}s',
              style: const TextStyle(
                fontWeight: FontWeight.bold
              )
            )
          ]
        )),
        h12,
        TextButton.icon(
          onPressed: (){
            _timer.stop();
            widget.onFinish.call(reCount);
          },
          label: Text('Thử lại ngay'.lang()),
          icon: const Icon(ViIcons.refresh),
        )
      ],
    );
  }
}
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
  };
}


class KeyboardFixer extends StatefulWidget {
  final Widget child;
  const KeyboardFixer({super.key, required this.child});

  @override
  State<KeyboardFixer> createState() => _KeyboardFixerState();
  static bool isIOS15() {
    if (kIsWeb || !Platform.isIOS) return false;
    final version = Platform.operatingSystemVersion;
    // ví dụ: "Version 15.8 (Build 19H12)"
    final match = RegExp(r'(\d+)\.(\d+)').firstMatch(version);
    if (match != null) {
      final major = int.tryParse(match.group(1) ?? '0') ?? 0;
      return major == 15;
    }
    return false;
  }
}

class _KeyboardFixerState extends State<KeyboardFixer> with WidgetsBindingObserver {
  late final bool _shouldFixIOS15;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _shouldFixIOS15 = KeyboardFixer.isIOS15();
  }



  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_shouldFixIOS15) return;

    if (state == AppLifecycleState.paused) {
      // Chỉ unfocus nếu là iOS 15 và app rời foreground (tắt màn hình / về home)
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}