import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:vhv_shared/vhv_shared.dart';


typedef LangFunction = String Function(String? text, {List<String> args, List? plural});

class Site extends Equatable{
  final String domain;
  final int? id;
  final String title;
  final String? mediaDomain;
  const Site({required this.domain, this.id, required this.title, this.mediaDomain});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'domain': domain,
      'title': title,
      'mediaDomain': mediaDomain,
      if(id != null)'id': id,
    };
  }
  static Site fromJson(Map data){
    return Site(
      domain: checkType<String>(data['domain']) ?? '',
      mediaDomain: checkType<String>(!empty(data['staticMediaDomain']) ? data['staticMediaDomain'] : data['mediaDomain']),
      title: checkType<String>(data['title']) ?? '',
      id: checkType<int>(data['id']),
    );
  }

  Site copyWith({
    String? domain,
    String? mediaDomain,
    String? title,
    required int? id,
  }){
    return Site(
      domain: domain ?? this.domain,
      mediaDomain: mediaDomain ?? this.mediaDomain,
      title: title ?? this.title,
      id: id == 0 ? null : id,
    );
  }

  Site get clone{
    return Site(
      domain: domain,
      mediaDomain: mediaDomain,
      title: title,
      id: id,
    );
  }

  @override
  List<Object?> get props => [id, domain, mediaDomain, title];
}


int differenceTime = 0;

Map factories = <String, dynamic>{};
bool get isAndroid => !kIsWeb && Platform.isAndroid;
bool get isFuchsia => !kIsWeb && Platform.isFuchsia;
bool get isIOS => !kIsWeb && Platform.isIOS;
bool get isWindows => !kIsWeb && Platform.isWindows;
bool get isLinux => !kIsWeb && Platform.isLinux;
bool get isMacOS => !kIsWeb && Platform.isMacOS;
bool get isDesktop => isLinux || isMacOS || isWindows;
// bool get isTablet => globalContext.isTablet ?? false;
// bool get isDarkMode => globalContext.isDarkMode ?? false;

final Logger logger = Logger();
final GlobalKey<NavigatorState> navigatorGlobalKey = GlobalKey<NavigatorState>();
BuildContext? appContext;
BuildContext get globalContext{
  return (navigatorGlobalKey.currentContext ?? appContext)!;
}

late List<DeviceOrientation> appOrientations;
Function(Map res)? setupData;
String currentLanguage = 'vi';
EdgeInsets basePadding = const EdgeInsets.symmetric(
  vertical: 12.0,
  horizontal: 16.0
);
double get paddingBase => basePadding.horizontal / 2;
const defaultSearchBarHeight = 44.0;
double contentPaddingBase = 12.0;
double lineSpacing = 20.0;
ConnectivityStatus? connectionStatus;
Directory? appDocumentDirectory;
AccountBase account = AccountBase();

BorderRadius baseBorderRadius = BorderRadius.circular(12);

class AuthHandler{

  final Function()? onBeforeLogout;
  final Function()? onLoggedOut;
  final Function()? onLogoutRedirect;
  final Function(Map account)? onBeforeLogin;
  final Function(Map account)? onLoggedIn;
  final Function(Map account)? onLoginRedirect;
  final String loginRouter;
  final bool requiredLogin;
  final bool useSiteId;
  final bool needFetchInfo;
  final bool hasRegister;
  final bool hasForgotPassword;

  const AuthHandler({

    this.onBeforeLogout,
    this.onLoggedOut,
    this.onLogoutRedirect,
    this.onBeforeLogin,
    this.onLoggedIn,
    this.onLoginRedirect,
    this.loginRouter = '/Login',
    this.requiredLogin = false,
    this.hasRegister = false,
    this.hasForgotPassword = false,
    this.useSiteId = false,
    this.needFetchInfo = true
  });
}
ScreenBreakpoints get breakpoints => ResponsiveSizingConfig.instance.breakpoints;

TracePerformanceBase? appPerformanceTrace;

class AppVersion{
  final String version;
  final String? buildNumber;
  String? latestVersion;
  String? pendingVersion;
  String? updateLink;
  bool requiredUpdate;
  String? _content;
  AppVersion({
    required this.version,
    required this.buildNumber,
    this.latestVersion,
    this.pendingVersion,
    this.updateLink,
    this.requiredUpdate = false,
    String? content
  }) : _content = content;
  bool get isPendingVersion{
    return pendingVersion == version;
  }
  bool get hasNewVersion{
    if (!empty(latestVersion)) {
      List news = latestVersion!.split('.');
      List olds = version.split('.');
      int index = 0;
      bool hasNew = false;
      if (!empty(news)) {
        for (var element in news) {
          int newTotal = parseInt(element);
          int old = (olds.length > index) ? parseInt(olds[index]) : 0;
          if (newTotal > old) {
            hasNew = true;
            break;
          } else if (newTotal < old) {
            hasNew = false;
            break;
          }
          index++;
        }
        return hasNew;
      }
    }
    return false;
  }
  String get content {
    if(_content != null){
      return _content!;
    }
    return '${"Đã có bản cập nhật mới! Phiên bản {newVersion} hiện đã sẵn sàng - phiên bản hiện tại {currentVersion}.".lang(namedArgs:{
      "newVersion": latestVersion ?? '',
      "currentVersion": version,
    })}\n${"Bạn có muốn cập nhật luôn?".lang()}';
  }
  void copyWith({
    String? latestVersion,
    String? pendingVersion,
    String? updateLink,
    bool? requiredUpdate,
    String? content
  }){
    this.latestVersion = latestVersion ?? this.latestVersion;
    this.pendingVersion = pendingVersion ?? this.pendingVersion;
    this.updateLink = updateLink ?? this.updateLink;
    this.requiredUpdate = requiredUpdate ?? this.requiredUpdate;
    _content = content ?? _content;
  }

  @override
  String toString(){
    return 'AppVersion(latestVersion: $latestVersion, pendingVersion: $pendingVersion, updateLink: $updateLink, requiredUpdate: $requiredUpdate)';
  }
}