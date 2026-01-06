import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:secugen_finger/finger_data.dart';

import 'secugen_finger_platform_interface.dart';

/// An implementation of [SecugenFingerPlatform] that uses method channels.
class MethodChannelSecugenFinger extends SecugenFingerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('secugen_finger');
  @override
  Future<Map?> create() async {
    var response = await methodChannel.invokeMethod('create', {});
    print("create: $response");
    return response;
  }
  @override
  onCreate() async {
    var response = await methodChannel.invokeMethod('onCreate', {});
  }
  @override
  onResume() async {
    var response = await methodChannel.invokeMethod('onCreate', {});
    print("create: $response");
    return response;
  }
  @override
  Future<Map?> capture() async {
    final res = await methodChannel.invokeMethod('capture', {
      'imageWidth': 100,
      'imageHeight': 100,
    });
    print("Capture: $res");
    return res;
  }

  @override
  Future<Map?> register() async {
    final res = await methodChannel.invokeMethod('register', {
      'imageWidth': 100,
      'imageHeight': 100,
    });
    print("Register: $res");
    return res;
  }

  @override
  // Future<Uint8List?> getData() async {
  Future<FingerData?> getData() async {
    final res = await methodChannel.invokeMethod('getData');
    print("getData: $res");

    return FingerData.fromMap(res);
  }

  getPlatformVersion() {}
}
