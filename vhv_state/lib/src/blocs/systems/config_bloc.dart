import 'dart:io';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vhv_config/vhv_config.dart';
import 'package:vhv_navigation/vhv_navigation.dart';
import 'package:vhv_network/vhv_network.dart';
import 'package:vhv_shared/vhv_shared.dart';
import 'package:vhv_state/src/bloc.dart';
import 'package:vhv_state/src/services/config_service.dart';
import 'package:vhv_storage/vhv_storage.dart';
import 'package:vhv_utils/vhv_utils.dart';
export 'package:connectivity_plus/connectivity_plus.dart';

enum ConfigStateStatus{initial, loading, loaded, error}
class AppAlertData extends Equatable{
  final String key;
  final int sortOrder;
  final String title;
  final String message;
  final List<ItemMenuAction> actions;
  final bool canPop;
  final Function()? onClose;
  final Widget Function(BuildContext context)? builder;

  const AppAlertData({
    required this.key,
    required this.title,
    required this.message,
    required this.actions,
    this.canPop = true,
    this.sortOrder = 0,
    this.onClose,
    this.builder
  });
  AppAlertData addClose(Function() onClose){
    return AppAlertData(
      key: key,
      title: title,
      message: message,
      actions: actions,
      canPop: canPop,
      sortOrder: sortOrder,
      builder: builder,
      onClose: onClose,
    );
  }

  @override
  List<Object?> get props => [key, title, message, actions, canPop, onClose, builder, sortOrder];
}

class ConfigState extends BaseState{
  const ConfigState({required this.data,
    this.status = ConfigStateStatus.initial,
    this.error,
    this.connectivityResult = const  [],
    this.components = const {},
    this.appLifecycleState = AppLifecycleState.resumed,
    this.alertData,
    this.percentLoading = 0.0
  });
  final Map data;
  final ConfigStateStatus status;
  final Object? error;
  final List<ConnectivityResult> connectivityResult;
  final Map<String, String> components;
  final AppLifecycleState appLifecycleState;
  final AppAlertData? alertData;
  final double percentLoading;

  @override
  List<Object?> get props => [data, status, error, connectivityResult, components, appLifecycleState, alertData, percentLoading];
  ConfigState copyWith({
    Map? data,
    ConfigStateStatus? status,
    Object? error,
    List<ConnectivityResult>? connectivityResult,
    AppLifecycleState? appLifecycleState,
    AppAlertData? alertData,
    bool clearAlert = false,
    double? percentLoading,
  }){
    Map<String, String>? components;
    if(data != null){
      components = Map<String, String>.from(checkType<Map>(data['components']) ?? {});
    }
    assert(percentLoading == null || (percentLoading >= 0 && percentLoading <= 100));
    return ConfigState(
      data: data ?? this.data,
      status: status ?? this.status,
      error: (status != null && status != ConfigStateStatus.error) ? null : error ?? this.error,
      connectivityResult: connectivityResult ?? this.connectivityResult,
      components: components ?? this.components,
      appLifecycleState: appLifecycleState ?? this.appLifecycleState,
      alertData: clearAlert ? null : (alertData ?? this.alertData),
      percentLoading: percentLoading ?? this.percentLoading
    );
  }

  bool hasAppComponent(String component){
    return components.containsKey(component);
  }
}

class ConfigBloc extends BaseCubit<ConfigState>{
  ConfigBloc({
    required this.site,
    this.sites,
    this.callbacks,
    this.asyncCallbacks,
    this.initializedCallbacks,
    this.boxes,
    required this.onHandledData,
  }):super(const ConfigState(data: {})){
    if(!kIsWeb) {
      BackButtonInterceptor.add(_myInterceptor);
    }
    _initApplicationControl();
  }
  final List<Function()>? callbacks;
  final List<Future<void> Function()>? asyncCallbacks;
  final List<Function()>? initializedCallbacks;
  final List<String>? boxes;
  final Site site;
  final Map<String, Site>? sites;
  final Function(Map data) onHandledData;

  static const _key = 'site';

  void _initApplicationControl(){
    VHVShared().initAction(
        call: call,
        applicationControl: (action){
          if(state.status != ConfigStateStatus.loading) {
            if(action is String) {

            }else if(action is Map){
              if(action['status'] == 'expired'){
                if(account.isLogin()) {
                  account.logout(
                    onSuccess: (){
                      Future.delayed(const Duration(seconds: 1),(){
                        if(!empty(action['message'])){
                          if(!globalContext.mounted){
                            return;
                          }
                          AppDialogs.showConfirmDialog(context: globalContext,
                              title: 'Thông báo'.lang(),
                              message: action['message'],
                              showCloseButton: true,
                              onConfirm: (){
                                appNavigator.pop();
                              },
                              textConfirm: 'Đã hiểu'.lang()
                          );
                        }
                      });
                    }
                  );
                }
              }
            }
          }
        }
    );
  }

  // void changedExtraStatus(String? status){
  //   emit(state.copyWith(extraStatus: status));
  // }

  Future<void> init()async{
    if(kDebugMode && factories.containsKey('header')){
      emit(state.copyWith(
        status: ConfigStateStatus.error,
        error: Exception('factories[header] need remove')
      ));
      return;
    }
    emit(state.copyWith(
      status: ConfigStateStatus.loading,
      percentLoading: 0
    ));
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      emit(state.copyWith(
        connectivityResult: result
      ));
      if (!result.contains(ConnectivityResult.none)
        && state.status == ConfigStateStatus.error
        && VHVNetwork.isNetworkErrorConnect(state.error)
      ) {
        _onInitialing();
      }
    });
    if(!kIsWeb) {
      appDocumentDirectory = await getApplicationSupportDirectory();
    }
    await ConfigService.initEndPoint(site: site, sites: sites);
    await _onInitialing();
    if(state.status == ConfigStateStatus.loaded) {
      try {
        if (!globalContext.mounted) {
          return;
        }
        globalContext.read<AccountBloc>().add(LoadAccount());
      } catch (_) {}
    }
  }

  @override
  void onChange(Change<ConfigState> change) {
    if(change.currentState.status != change.nextState.status){
      ApplicationStateNotifier().refresh();
    }
    super.onChange(change);
  }

  void updateLifecycle(AppLifecycleState appState){
    if(state.appLifecycleState != appState) {
      if(appState == AppLifecycleState.resumed
          && hasComponent('Extra.Notification')
        && account.isLogin()
      ){
        getTotalNotification();
      }
      emit(state.copyWith(
        appLifecycleState: appState
      ));
    }
  }

  Future<void> getTotalNotification()async{
    final res = await call('Common.Notification.Account.Notification.getTotal',
      forceCache: true,
      cacheTime: Duration(seconds: 5)
    );
    if (!empty(res)) {
      AppInfo.notificationCounter.value = parseInt(res);
    } else {
      AppInfo.notificationCounter.value = 0;
    }
  }

  bool _myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if(AppLoadingManager.instance.isShowLoading){
      return true;
    }
    return false;
  }

  Future<void> _onInitialing()async{
    await Future.wait([
      _initCallbacks(),
      _onLoadingMinTime(),
    ]);
    if(state.status == ConfigStateStatus.loading) {
      emit(state.copyWith(
          status: ConfigStateStatus.loaded
      ));
    }
    _emitPercent(100);

    if(initializedCallbacks != null){
      await Future.wait(initializedCallbacks!.map((func)async{
        await func();
      }));
    }
  }


  Future<void> _initCallbacks()async{
    ///emit(state.copyWith(
    //       status: ConfigStateStatus.loading,
    //       percentLoading: 0
    //     ));
    final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
    emit(state.copyWith(
      connectivityResult: connectivityResult,
      percentLoading: (asyncCallbacks?.isNotEmpty == true) ? 10 : 60
    ));
    if(asyncCallbacks?.isNotEmpty == true){
      int i = 1;
      await Future.wait(asyncCallbacks!.map((e)async{
        await e();
        _emitPercent(10 + ((70 / asyncCallbacks!.length) * i));
        i++;
      }));
    }
    callbacks?.forEach((func) => func());
    await _loadData();

  }
  Future<void> _onLoadingMinTime()async{
    if(!empty(AppInfo.getExtra('minLoadingTime'))){
      await Future.delayed(Duration(
          milliseconds: parseInt(AppInfo.getExtra('minLoadingTime'))
        )
      );
    }
    return;
  }
  Future<bool> _loadData([bool force = false])async{
    ///percentLoading: 70
    if(state.data.isEmpty && !force){
      final localData = Setting().get(_key);
      if(localData is Map && localData.isNotEmpty){
        emit(state.copyWith(data: localData));
      }
    }
    final String? token = Setting('Config').get('tokenPushNotification');
    factories['appVersion'] = AppInfo.version;
    factories['deviceId'] = !empty(token)?token:'mobile';
    final date = DateTime.now();

    try{
      final res = await call('CMS.Application.getInfo',
          params: {
            'setClientLanguage': currentLanguage,
            'deviceId': !empty(token)?token:'mobile',
            if(!empty(factories['notShowUpdate']))'notShowUpdate': 1,
            if(!empty(factories['menuType']))'menuType': factories['menuType'],
          },
          handleCatch: true,
        // handleSpecialCase: true
      );

      if(res is Map && res.isNotEmpty){
        AppInfo.setAppVersion(res);
        await _saveComponent(res);
        await Future.wait([
          _handleData(res, date),
          _saveData(res)
        ]);
        _emitPercent(99);
        await Future.delayed(Duration(milliseconds: 500));
        emit(state.copyWith(
          data: res,
          status: ConfigStateStatus.loaded,
        ));

      }else if(res == 'LoginVerify'){
        _emitPercent(95);
        account.needVerify(true);
      }else{
        _emitPercent(95);
        _trackLogError(res);
      }
    }catch(e){
      _emitPercent(95);
      _trackLogError(e);
      if(state.data.isEmpty && VHVNetwork.isNetworkErrorConnect(e)){
        emit(state.copyWith(
          status: ConfigStateStatus.error,
          error: e,
          data: {}
        ));
      }else if(VHVNetwork.isRedirect(e)){
        if(VHVNetwork.getLinkRedirect(e).endsWith('/page/404')){
          account.logout(force: true);
        }
      }
    }

    return state.status == ConfigStateStatus.loaded;
  }

  void _emitPercent(double percent){
    if(state.percentLoading >= percent){
      return;
    }
    emit(state.copyWith(
      percentLoading: percent
    ));
  }

  void _trackLogError(Object error)async{
    if(factories['logForAppInfo'] is Function){
      try{
        final res = await BasicAppConnect.getDio().get('${AppInfo.domain}/api/CMS/Application/getInfo?OS=${getPlatformOS()}');
        if(res.data == 'LoginVerify'){
          return;
        }
        factories['logForAppInfo'](<String, Object>{
          'error': error.toString(),
          'response': res.data,
          'domain': AppInfo.domain,
        });
      }catch(e, _){
        try{
          final res = await BasicAppConnect.getDio().get(AppInfo.domain);
          factories['logForAppInfo'](<String, Object>{
            'error': error.toString(),
            'response': res.data,
            'domain': AppInfo.domain,
            'inHome': 1
          });
        }catch(e, _){
          factories['logForAppInfo'](<String, Object>{
            'error': e.toString(),
            'domain': AppInfo.domain,
            'trackLogError': 1
          });
        }
      }
    }
  }

  Future<bool> refresh([bool hasLoading = false])async{
    if(hasLoading){
      emit(state.copyWith(
        status: ConfigStateStatus.loading
      ));
    }
    return await _loadData(true);
  }

  Future<void> _saveComponent(Map res0)async{
    if(res0['components'] is Map){
      await Setting().put('components', res0['components']);
    }else{
      await Setting().delete('components');
    }
  }

  Future<void> _handleData(Map res0, DateTime startTime)async{

    final res2 = await AppInfo.checkSiteExpired({
      'siteStatus': res0['status'],
      'siteExpiredTime': res0['expiredTime'],
      'siteTitle': res0['title'],
      'siteCode': res0['siteCode'],
    }, ()async{
      appFound(res0);
    });
    if(!res2){
      return;
    }
    if(!empty(res0['systemMaintenance'])){
      appNavigator.pushNamedAndRemoveAllUntil('Maintenance', arguments: {
        'message': res0['systemMaintenance']
      });
    }else{
      if(res0['userData'] is Map){
        if (empty(factories['notInitUserData'])) {
          await account.update(res0['userData']);
        }
      }
      if(!res0.containsKey('androidPendingVersion') && res0.containsKey('androidpendingVersion')){
        res0.addAll(<String, dynamic>{
          'androidPendingVersion': res0['androidpendingVersion']
        });
      }
      if(!empty(res0['serverTime'])){
        await checkServerTime(res0['serverTime'], startTime);
      }
      Setting().put('getInfoTime', time());
      if(!empty(res0['id'])) {
        if (!empty(res0['faceDataNote'])) {
          factories['faceDataNote'] = res0['faceDataNote'];
        }
        if (!empty(res0['currency'])) {
          factories['currency'] = res0['currency'];
        }
        if (!empty(res0['shortCurrency'])) {
          factories['shortCurrency'] = res0['shortCurrency'];
        }
        AppInfo.mediaDomain = res0['staticDomain'];
        res0.removeWhere((key, value) => (value is IconData || key is IconData));
        await _saveData(res0);
        await onHandledData(res0);
        _addAlertData(checkType<Map>(res0['alert']));
        if(setupData != null){
          await setupData!(res0);
        }

      }else{
        Future.delayed(const Duration(seconds: 2),(){
          appFound(res0);
        });
      }
    }
  }
  final List<AppAlertData> _alerts = [];

  /// Usage: Tạo thông báo trên toàn bộ hệ thống: thông báo cập nhật, thông báo bảo trì, ....
  void showAlert(AppAlertData newAlert){
    final alert = newAlert.addClose(()async{
      await newAlert.onClose?.call();
      closeAlert();
    });
    if(state.alertData != null){
      if(state.alertData?.key == alert.key){
        emit(state.copyWith(
          alertData: alert,
        ));
      }else{
        _alerts.add(alert);
        _alerts.sort((a, b) => b.sortOrder.compareTo(a.sortOrder));
      }
    }else{
      emit(state.copyWith(
        alertData: alert,
      ));
    }
  }
  ///Usage: Đóng thông báo
  void closeAlert(){
    if(state.alertData != null) {
      if (_alerts.isEmpty) {
        emit(state.copyWith(
            clearAlert: true
        ));
      } else {
        final showData = _alerts.removeAt(0);
        emit(state.copyWith(
            alertData: showData
        ));
      }
    }
  }
  /// Usage: Xóa toàn bộ thông báo, cả thông báo đang hiện và thông báo đang chờ
  void clearAllAlert(){
    _alerts.clear();
    closeAlert();
  }
  void _addAlertData(Map? alert){
    const key = 'alert';
    if(alert is Map) {
      showAlert(AppAlertData(
        key: key,
        title: alert['title'] ?? 'Thông báo'.lang(),
        message: (alert['content'] != null) ? alert['content'] : '',
        canPop: empty(alert['notDismiss']),
        actions: [
          ItemMenuAction(
              label: alert['textConfirm'] ?? 'Đồng ý'.lang(),
              iconData: ViIcons.activity,
              onPressed: () {
                if (alert['router'] != null) {
                  String? link;
                  if (alert['router'] is Map) {
                    String? key;
                    if (kIsWeb) {
                      key = 'web';
                    } else {
                      if (Platform.isIOS) key = 'ios';
                      if (Platform.isAndroid) key = 'android';
                      if (Platform.isFuchsia) key = 'fuchsia';
                      if (Platform.isWindows) key = 'windows';
                    }
                    if (alert['router'].containsKey(key)) {
                      link = alert['router'][key];
                    }
                  } else if (alert['router'] is String) {
                    link = alert['router'];
                  }
                  if (link!.startsWith('/')) {
                    appNavigator.pushNamed(link, arguments: alert['params']);
                  } else if (link.startsWith('http')) {
                    urlLaunch(link, forceWebView: !empty(alert['useWebView']));
                  }
                }
                if (empty(alert['notDismiss'])) {
                  closeAlert();
                }
              }
          ),
          if(empty(alert['notDismiss']))ItemMenuAction(
              label: alert['textCancel'] ?? 'Hủy'.lang(),
              iconData: ViIcons.x_small,
              onPressed: (){
                closeAlert();
              }
          ),
        ]
      ));
    }else{
      if(state.alertData?.key == key) {
        closeAlert();
      }
    }
  }


  Future<void> _saveData(Map data)async{
    await Setting().put(_key, data);
  }

  void setError(){
    emit(state.copyWith(
      status: ConfigStateStatus.error,
      error: 'Not connect',
      data: {}
    ));
    // Future.delayed(Duration(seconds: 10),(){
    //   if(state.status == ConfigStateStatus.error){
    //     refresh(true);
    //   }
    // });
  }
}