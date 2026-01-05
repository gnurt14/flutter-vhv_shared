import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart' as package_info;
import 'package:vhv_network/vhv_network.dart';
import 'package:vhv_shared/vhv_shared.dart';
import 'package:vhv_shared/vhv_shared.dart' as vhv_shared;
import 'package:vhv_storage/vhv_storage.dart';


// ignore: non_constant_identifier_names
var AppInfo = _AppInfo.instance;

class _AppInfo {
  _AppInfo._();
  static _AppInfo? _instance;
  static _AppInfo get instance {
    _instance ??= _AppInfo._();
    return _instance!;
  }

  bool isTesting = false;
  String remindPermission  = 'Bạn đã từ chối quyền truy cập "{}". Một số tính năng trong ứng dụng có thể sẽ không hoạt động cho tới khi bạn cấp quyền!';

  bool get isDisconnect{
    return false;
    // return connectionStatus == ConnectivityStatus.offline;
  }

  String get getOS => getPlatformOS();

  bool get hasRequiredLogin => _hasRequiredLogin;
  bool _hasRequiredLogin = false;
  void setRequiredLogin(){
    _hasRequiredLogin = true;
  }
  void notificationIncrement(){
    notificationCounter.value++;
  }

  final _extraData = <String, dynamic>{};
  ///minLoadingTime: Thời gian load tối thiểu của hàm getInfo (Kiểu int, đơn vị milliseconds)
  void setExtraData(Map<String, dynamic> extraData, [bool force = false])async{
    if(force){
      _extraData.clear();
    }
    _extraData.addAll(extraData);
  }
  dynamic getExtra(String key){
    return _extraData[key];
  }

  ValueNotifier<int>? _notificationCounter;
  ValueNotifier<int> get notificationCounter{
    _notificationCounter ??= ValueNotifier<int>(0);
    return _notificationCounter!;
  }
  void resetCounter(){
    if(_notificationCounter != null){
      _notificationCounter?.value = 0;
    }
    if(_messageCounter != null){
      _messageCounter?.value = 0;
    }
  }

  ValueNotifier<int>? _messageCounter;
  ValueNotifier<int> get messageCounter{
    _messageCounter ??= ValueNotifier<int>(0);
    return _messageCounter!;
  }
  Function()? onConnectionErrorBuilder;
  String logo(BuildContext context){
    try {
      final theme = Theme.of(context).extension<AppThemeExtension>();
      return theme?.logo ?? '';
    }catch(_){
      return '';
    }
  }

  int timeAutoSearch = 1500;
  Widget? loginLoading;

  Future<void> reload()async{

  }

  package_info.PackageInfo? _packageInfo;
  String get bundleId => (_packageInfo != null?((_packageInfo!.packageName=="vn.edui.qlcl")?"vn.edui":_packageInfo!.packageName):'');

  String? iOSAppId;
  String get deviceModel => DeviceService.deviceModel;
  String get deviceBrand => DeviceService.deviceBrand;
  String get osVersion => DeviceService.osVersion;
  int get sdkInt => DeviceService.sdkInt;
  String get browserName => DeviceService.browserName;
  String get userAgent => DeviceService.userAgent;
  String get deviceId => DeviceService.deviceId;
  double? get textScaleFactor => _textScaleFactor;
  double? _textScaleFactor;
  void setTextScaleFactor(double? value, {bool forceUpdate = false}){
    _textScaleFactor = value;
  }
  Future<void> init() async {
    try{
      _packageInfo = await getPackageInfo();
    }catch(_){}
    mediaDomain = AppInfo.domain;
  }

  String? get version => appVersion.version;
  String? get buildNumber => appVersion.buildNumber;

  String? get lastestVersion => appVersion.latestVersion;
  String? get pendingVersion => appVersion.pendingVersion;
  bool get hasNewVersion => appVersion.hasNewVersion;
  bool get isPendingVersion => appVersion.isPendingVersion;
  late AppVersion appVersion;
  void setAppVersion(Map data){
    final appSettingVersion = checkType<Map>(data['appSettingVersion']) ?? {};
    if(appSettingVersion.isEmpty && data['appInfo'] is Map){

      final ver = _getLastVersion(data);
      if(ver.isNotEmpty){
        appSettingVersion.addAll({
          'requiredUpdate': !empty(ver['requiredUpdate']),
          'link': ver['link'],
          'minVersion': ver['version'],
          'pendingVersion': ver['pendingVersion'],
          'content': ver['content']
        });
      }
    }
    if(appSettingVersion.isEmpty){
      appSettingVersion.addAll(
        <String, dynamic>{for(String k in [
          'androidId', 'iosId', 'huaweiId',
          'androidLink', 'iosLink', 'huaweiLink',
          'minVersion', 'pendingVersion',
          'androidMinVersion', 'androidPendingVersion',
          'huaweiMinVersion', 'huaweiPendingVersion',
          'iosMinVersion', 'iosPendingVersion',
        ])k: data[k]});
    }
    final platform = AppInfo.isAndroid && AppInfo.deviceBrand == 'HUAWEI' ? 'huawei' : getPlatformOS().toLowerCase();
    if(!empty(appSettingVersion['${platform.toLowerCase()}Link'])){
      appSettingVersion.addAll(<String, dynamic>{
        'link': appSettingVersion['${platform.toLowerCase()}Link']
      });
    }

    final version = {
      'latestVersion': (appSettingVersion['${platform}MinVersion'] ?? appSettingVersion['minVersion'] ?? ''),
      'pendingVersion': (appSettingVersion['${platform}PendingVersion'] ?? appSettingVersion['pendingVersion'] ?? ''),
      if(empty(appSettingVersion['link']))...{
        if(AppInfo.isAndroid && AppInfo.deviceBrand != 'HUAWEI'
            && !empty(appSettingVersion['androidId']))
          'link': 'https://play.google.com/store/apps/details?id=${appSettingVersion['androidId']}',
        if(AppInfo.isAndroid && AppInfo.deviceBrand == 'HUAWEI'
            && !empty(appSettingVersion['huaweiId']))
          'link': 'https://appgallery.huawei.com/app/${appSettingVersion['huaweiId']}',
        if(AppInfo.isIOS && !empty(appSettingVersion['iosId']))'link': 'https://apps.apple.com/us/app/${appSettingVersion['iosId']}',
      } else ...{
        'link': appSettingVersion['link']
      },
      if(!empty(appSettingVersion['link']))'link': appSettingVersion['link'],
      'requiredUpdate': appSettingVersion['requiredUpdate'],
      'content': appSettingVersion['content']
    };
    appVersion.copyWith(
      latestVersion: version['latestVersion'],
      pendingVersion: version['pendingVersion'],
      updateLink: version['link'],
      content: version['content'],
      requiredUpdate: !empty(version['requiredUpdate']),
    );
  }
  Map _getLastVersion(Map data) {
    final versionInfo = data['appInfo'];
    if (!empty(versionInfo)) {
      Map appInfo = (versionInfo is String)
          ? json.decode(versionInfo)
          : ((versionInfo is Map) ? versionInfo : {});
      if(appInfo.containsKey('huawei') && AppInfo.deviceBrand == 'HUAWEI'){
        return appInfo['huawei'] ?? {};
      }
      return appInfo[getPlatformOS().toString().toLowerCase()] ?? {};
    }
    return {};
  }

  dynamic get(String key) {
    return this[key];
  }
  bool containsKey(String key) {
    return data.containsKey(key);
  }

  List? getBlocks(String pageCode) {
    if (data.containsKey('pages') &&
        data['pages'] is Map &&
        data['pages'][pageCode] is Map) {
      final blocks = data['pages'][pageCode]['blocks'];
      if (blocks != null && (blocks is List || blocks is Map)) {
        return (blocks is Map) ? blocks.values.toList() : blocks;
      }
    }
    return null;
  }

  dynamic remove(String key){
    return data.remove(key);
  }

  dynamic put(String key, dynamic value) {
    this[key] = value;
    return value;
  }

  dynamic operator [](String key) {
    return data[key];
  }

  void operator []=(String key, dynamic value) {
    final dataNew = {...data}..addAll(<String, dynamic>{key: value});
    Setting().put('site', dataNew);
  }

  String get rootAppDomain => VHVNetwork.config.rootAppDomain;
  String? get forceAppDomain => VHVNetwork.config.forceAppDomain;

  Future<bool> checkSiteExpired(Map? res, [Function()? functionLogout]) async {
    if (res is Map) {
      if(res['siteStatus'].toString() == '1'){
        return true;
      }
      if (((!empty(res['siteStatus'], true) &&
          res['siteStatus'].toString() != '1') ||
          (!empty(res['siteExpiredTime']) &&
              parseInt(res['siteExpiredTime']) < time()))) {
        if (functionLogout == null) {
          showMessage(
              !empty(factories['appFoundMessage'])
                  ? (factories['appFoundMessage'] is Function(Map)
                  ? factories['appFoundMessage']({
                'title': res['siteTitle'] ?? res['title'],
                'code': res['siteCode'] ?? res['code']
              })
                  : factories['appFoundMessage'])
                  : 'Ứng dụng hết hạn sử dụng!',
              timeShow: 10,
              type: 'warning');
          // await call('Member.User.logout');
        } else {
          await functionLogout();
        }
        return false;
      }
    }
    return true;
  }

  Map get data => Setting().get('site') ?? {};
  String get id => '${VHVNetwork.id ?? ''}';
  String get title => VHVNetwork.title;
  String get domain => checkDomainValid(VHVNetwork.domain);
  String get mediaDomain => checkDomainValid(VHVNetwork.mediaDomain);
  String get staticDomain => checkDomainValid(data['staticDomain'] ?? domain);
  String get siteDomain => checkDomainValid(data['siteDomain'] ?? domain);

  set mediaDomain(String? domain) => VHVNetwork.mediaDomain;

  String get publishDomain{
    String domain = !empty(get('domain')) ? get('domain') : this.domain;
    if(!domain.startsWith('http')){
      domain = 'https://$domain';
    }
    return domain;
  }
  String get language => currentLanguage;
  Map get lastAppVersion => _getLastVersion(data);
  String get phone => data['phone'] ?? '';
  String get fax => data['fax'] ?? '';
  String get hotline => data['hotline'] ?? '';
  String get email => data['email'] ?? '';
  String get cmsGroupId => data['cmsGroupId'] ?? '';
  String get address => data['address'] ?? '';
  String get shortCurrency => !empty(factories['shortCurrency']) ? factories['shortCurrency'] : data['shortCurrency'] ?? '';
  String get currency => !empty(factories['currency']) ? factories['currency'] : data['currency'] ?? '';
  String get defaultCurrency => !empty(factories['defaultCurrency']) ? factories['defaultCurrency'] : data['defaultCurrency'] ?? '';
  String get locationMap => (!empty(data['locationMap']) && data['locationMap'].toString().trim().length > 2) ? data['locationMap'] : data['location'];

  String? _packageName;
  FutureOr<String> get packageName => _packageName ?? getPackageInfo().then((value){
    _packageName ??= value.packageName;
    return value.packageName;
  });
  String? _appName;
  FutureOr<String> get appName => _appName ?? getPackageInfo().then((value){
    _appName ??= value.appName;
    return value.appName;
  });
  String checkDomainValid(String? domain) {
    if (domain != null) {
      if ((domain.toString().startsWith('https://')) ||
          (domain.toString().startsWith('http://'))) {
        return domain;
      } else {
        return 'https://$domain';
      }
    }
    return '';
  }

  Future<package_info.PackageInfo> getPackageInfo()async{
    _packageInfo ??= await package_info.PackageInfo.fromPlatform();
    return _packageInfo!;
  }



  Future<void> clearData()async{
  }

  @override
  String toString() {
    return data.toString();
  }
  VoidCallback accessDenied = (){};
  bool get kIsWeb => foundation.kIsWeb;
  bool get isIOS => vhv_shared.isIOS;
  bool get isAndroid => vhv_shared.isAndroid;
  bool get isFuchsia => vhv_shared.isFuchsia;
  bool get isLinux => vhv_shared.isLinux;
  bool get isMacOS => vhv_shared.isMacOS;
  bool get isWindows => vhv_shared.isWindows;
  bool get isDesktop => vhv_shared.isDesktop;


  StackTrace? getStackTrace(String stopContent, [String label = 'At file']){
    String stack = '';
    bool stop = false;
    final list = StackTrace.current.toString().split('\n');
    list.removeWhere((e) => e == '<asynchronous suspension>');
    for(var i in list){
      if(stop && i.toString().contains(stopContent)){
        continue;
      }
      if(stop){
        stack = i;
        break;
      }
      if(i.toString().contains(stopContent)){
        stop = true;
      }
    }
    if(!empty(stack)){
      if(RegExp(r'(package:[a-zA-Z0-9/._]+)').hasMatch(stack)) {
        final r = RegExp(r'(package:[a-zA-Z0-9/._]+:\d+:\d+)').firstMatch(stack);
        if(!empty(r?.group(1))) {
          return StackTrace.fromString('$label: ${r?.group(1)}');
        }
      }
    }
    return null;
  }

  Future<void> changeForceDomain(String domain, {dynamic id, String? title}){
    return VHVNetwork.changeForceDomain(domain, id: id, title: title);
  }
  Future<void> changeSite({int? id, String? title}){
    return VHVNetwork.changeInfo(id: id, title: title);
  }


  void unfocus ([BuildContext? context]){
    try{
      if(context != null){
        return FocusScope.of(context).unfocus();
      }
      return FocusManager.instance.primaryFocus?.unfocus();
    }catch(_){return;}
  }
  bool nextFocus ([BuildContext? context]){
    try{
      if(context != null){
        return FocusScope.of(context!).nextFocus();
      }
      return FocusManager.instance.primaryFocus?.nextFocus() ?? false;
    }catch(_){return false;}
  }
  bool previousFocus ([BuildContext? context]){
    try{
      if(context != null){
        return FocusScope.of(context!).previousFocus();
      }
      return FocusManager.instance.primaryFocus?.previousFocus() ?? false;
    }catch(_){return false;}
  }
  void requestFocus ([FocusNode? focusNode, BuildContext? context]){
    try{
      if(context != null){
        return FocusScope.of(context).unfocus();
      }
      return FocusManager.instance.primaryFocus?.requestFocus(focusNode);
    }catch(_){return;}
  }


  ///Dùng để xử lý các trường hợp dùng nextFocus, previousFocus không đúng ý định
  ///Ví dụ như trong form text nhập mật khẩu có icon ẩn hiện mật khẩu, việc dùng nextFocus sẽ focus vào icon button ẩn hiện mật khẩu
  ///Trong trường hợp này sẽ dùng focusInDirection(TraversalDirection.down) để xuống ô input tiếp theo;
  bool focusInDirection(TraversalDirection direction) => FocusManager.instance.primaryFocus?.focusInDirection(direction) ?? false;
}
