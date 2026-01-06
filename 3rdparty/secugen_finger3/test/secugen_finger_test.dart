import 'package:flutter_test/flutter_test.dart';
import 'package:secugen_finger/secugen_finger.dart';
import 'package:secugen_finger/secugen_finger_platform_interface.dart';
import 'package:secugen_finger/secugen_finger_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSecugenFingerPlatform with MockPlatformInterfaceMixin implements SecugenFingerPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final SecugenFingerPlatform initialPlatform = SecugenFingerPlatform.instance;

  test('$MethodChannelSecugenFinger is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSecugenFinger>());
  });

  test('getPlatformVersion', () async {
    SecugenFinger secugenFingerPlugin = SecugenFinger();
    MockSecugenFingerPlatform fakePlatform = MockSecugenFingerPlatform();
    SecugenFingerPlatform.instance = fakePlatform;

    expect(await secugenFingerPlugin.getPlatformVersion(), '42');
  });
}
