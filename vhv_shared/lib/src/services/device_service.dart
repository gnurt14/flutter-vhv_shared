import 'dart:convert';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoData{
  final String? uniqueDeviceId;
  final String? browserName;
  final String? userAgent;
  final String? osVersion;

  final String? deviceName;
  final String? deviceModel;
  final String? deviceBrand;
  final bool? isPhysicalDevice;

  DeviceInfoData(this.uniqueDeviceId, {
    this.deviceName,
    this.browserName,
    this.userAgent,
    this.deviceModel,
    this.osVersion,
    this.deviceBrand,
    this.isPhysicalDevice
  });
  Map<String, dynamic> toMap(){
    return <String, dynamic>{
      if(uniqueDeviceId != null)'uniqueDeviceId': uniqueDeviceId,
      if(browserName != null)'browserName': browserName,
      if(userAgent != null)'userAgent': userAgent,
      if(osVersion != null)'osVersion': osVersion,
      if(deviceName != null)'deviceName': deviceName,
      if(deviceModel != null)'deviceModel': deviceModel,
      if(deviceBrand != null)'deviceBrand': deviceBrand,
      if(isPhysicalDevice != null)'isPhysicalDevice': isPhysicalDevice == true ? 1 : 0,
    };
  }
  static DeviceInfoData fromJson(Map data){
    return DeviceInfoData(
      data['uniqueDeviceId'] ?? '',
      browserName: data['browserName'],
      userAgent: data['userAgent'],
      osVersion: data['osVersion'] ?? data['systemVersion'],
      deviceName: data['deviceName'] ?? data['computerName'],
      deviceModel: data['deviceModel'],
      deviceBrand: data['deviceBrand'] ?? data['brand'],
      isPhysicalDevice: data['isPhysicalDevice'] != null ? data['isPhysicalDevice'].toString() == '1' : null,
    );
  }
}

class DeviceService{
  DeviceService._();
  static Map get data => _data?.toMap() ?? <String, dynamic>{};
  static DeviceInfoData? _data;

  // Future<bool> isRegistered([String? accountCode])async{
  //   if(empty(accountCode) && !account.isLogin()){
  //     return false;
  //   }
  //   final token = await AppSecureStorage().get('loginToken',
  //       accountName: !empty(accountCode) ? accountCode : account.code);
  //   return token != null;
  // }

  static Future<void> _getDeviceId()async{
    _deviceId = (await MobileDeviceIdentifier().getDeviceId()) ?? '';
    if(_deviceId != '') {
      _deviceId = base64.encode(utf8.encode(_deviceId));
    }

  }
  static String get deviceModel => _data?.deviceModel ?? '';
  static String get deviceBrand => _data?.deviceBrand ?? '';
  static String get osVersion => _data?.osVersion ?? '';
  static String get browserName => _data?.browserName ?? '';
  static String get userAgent => _data?.userAgent ?? '';
  static String _deviceId = '';
  static String get deviceId => _deviceId;
  static int _sdkInt = 0;
  static int get sdkInt => _sdkInt;
  static Future<Map> initTest(BaseDeviceInfo fakeData)async{
    return _initData(fakeData);
  }
  static Future<Map> init()async{
    try{
      final data = await DeviceInfoPlugin().deviceInfo;
      await _getDeviceId();
      return _initData(data);
    }catch(_){
      return {};
    }
  }

  static Map _initData(BaseDeviceInfo data){
    if(data is AndroidDeviceInfo){
      _sdkInt = data.version.sdkInt;
    }
    _data = DeviceInfoData.fromJson({
      ...data.data,
      'uniqueDeviceId': deviceId,
      if(data is AndroidDeviceInfo)'osVersion': data.version.release
    });
    return data.data;
  }
}