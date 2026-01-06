import 'dart:typed_data';

import 'package:secugen_finger/finger_data.dart';

import 'secugen_finger_platform_interface.dart';

class SecugenFinger {
  Future<Map?> create() {
    return SecugenFingerPlatform.instance.create();
  }

  Future<Map?> capture() {
    return SecugenFingerPlatform.instance.capture();
  }

  Future<Map?> register() {
    return SecugenFingerPlatform.instance.register();
  }
  onCreate() {
    return SecugenFingerPlatform.instance.onCreate();
  }
  onResume() {
    return SecugenFingerPlatform.instance.onResume();
  }

  Future<FingerData?> getData() {
    return SecugenFingerPlatform.instance.getData();
  }
}
