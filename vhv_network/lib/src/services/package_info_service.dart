import 'dart:async';
import 'package:package_info_plus/package_info_plus.dart' as package_info;
class PackageInfoService{
  PackageInfoService._();
  static package_info.PackageInfo? _packageInfo;
  static Future<package_info.PackageInfo> _getPackageInfo()async{
    _packageInfo ??= await package_info.PackageInfo.fromPlatform();
    return _packageInfo!;
  }
  static String? _version;
  static FutureOr<String> get version => _version ?? _getPackageInfo().then((value){
    _version ??= value.version;
    return  value.version;
  });
  static String? _buildNumber;
  static FutureOr<String> get buildNumber => _buildNumber ?? _getPackageInfo().then((value){
    _buildNumber ??= value.buildNumber;
    return value.buildNumber;
  });
  static String? _packageName;
  static FutureOr<String> get packageName => _packageName ?? _getPackageInfo().then((value){
    _packageName ??= value.packageName;
    return value.packageName;
  });
  static String? _appName;
  static FutureOr<String> get appName => _appName ?? _getPackageInfo().then((value){
    _appName ??= value.appName;
    return value.appName;
  });
}